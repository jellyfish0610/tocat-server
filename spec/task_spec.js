var config = require('./config');
var url = config.url;


frisby.create('Correct task creation')
 .post(url + '/tasks', {"external_id": "TST-101" })
 .expectStatus(201)
 .afterJSON(function(task){
    frisby.create('Initial task settings')
      .get(url + '/task/' + task.id)
      .expectStatus(200)
      .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
      .afterJSON(function(){
          frisby.create('DELETE task - not allowed')
            .delete(url + '/task/' + task.id)
            .expectStatus(405)
            .toss();

          frisby.create('Attribute paid should not be updatable directly')
            .post(url + '/task/' + task.id,
            {
              'paid' : true
            })
            .expectStatus(405)
            .afterJSON(function(){
              frisby.create('Attribute paid should not be updatable directly')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
                .toss();
            })
            .toss();


          frisby.create('Attribute budget should not be updatable directly')
            .post(url + '/task/' + task.id,
            {
              'budget' : 10
            })
            .expectStatus(405)
            .afterJSON(function(){
              frisby.create('Attribute budget should not be updatable directly')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
                .toss();
            })
            .toss();

          frisby.create('Attribute resolver should not be updatable directly')
            .post(url + '/task/' + task.id,
            {
              'paid' : true,
              'budget' : 10,
              'resolver' : {
                'id' : 1
              },
              'accepted' : true
            })
            .expectStatus(405)
            .afterJSON(function(){
              frisby.create('Attribute resolver should not be updatable directly')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
                .toss();
            })
            .toss();

          frisby.create('Attribute accepted should not be updatable directly')
            .post(url + '/task/' + task.id,
            {
              'accepted' : true
            })
            .expectStatus(405)
            .afterJSON(function(){
              frisby.create('Attribute accepted should not be updatable directly')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
                .toss();
            })
            .toss();

          frisby.create('Attribute accepted should not be updatable directly')
            .post(url + '/task/' + task.id,
            {
              'external_id' : "true"
            })
            .expectStatus(405)
            .afterJSON(function(){
              frisby.create('Attribute accepted should not be updatable directly')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
                .toss();
            })
            .toss();

          frisby.create('Attribute external_id should not be updatable directly')
            .post(url + '/task/' + task.id,
            {
              'external_id' : 'test new'
            })
            .expectStatus(405)
            .afterJSON(function(){
              frisby.create('Attribute external_id should not be updatable directly')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'budget' : 0, 'paid' : false, 'resolver' : {}, 'accepted' : false, 'external_id' : 'TST-101'})
                .toss();
            })
            .toss();
      })
      .toss();
 })
 .toss();

frisby.create('Missed task external id')
  .post(url + '/tasks',{})
 .expectStatus(422)
 .expectJSON({errors:['Missing external task ID']})
 .toss();


frisby.create('Correct order creation')
  .post(url + '/orders',
       {
          "invoiced_budget": 1500.00,
          "allocatable_budget": 1000.00,
          "name" : "Test",
          "description" : "This is just a test order for SuperClient",
          "team":  {
            "id" : 1
          }
       })
  .expectStatus(201)
  .afterJSON(function(order) {
    frisby.create('Second order creation')
      .post(url + '/orders',
       {
          "invoiced_budget": 2000.00,
          "allocatable_budget": 500.00,
          "name" : "Test2",
          "description" : "This is just a test order for SuperClient",
          "team":  {
            "id" : 1
          }
       })
      .afterJSON(function(order2){
            frisby.create('Correct task creation')
              .post(url + '/tasks', {"external_id": "TST-102" })
              .expectStatus(201)
              .afterJSON(function(task){

                frisby.create('Set negative task budget')
                  .post(url + '/task/' + task.id + '/budget', {'budget' : [
                      {
                        'order_id' : order.id,
                        'budget'   : -1
                      }]})
                  .expectStatus(422)
                  .expectJSON({errors:['Budget can not be negative']})
                  .toss();

                frisby.create('Invalid budget data')
                  .post(url + '/task/' + task.id + '/budget', {'budget' : [
                      { 'budget' : 10},

                      {
                        'order_id' : order2.id,
                        'budget'   : 150
                      }
                      ]
                    })
                  .expectStatus(422)
                  .expectJSON({errors:["Order can't be blank"]})
                  .toss();

                frisby.create('Set task budgets')
                  .post(url + '/task/' + task.id + '/budget', {'budget' : [
                      {
                        'order_id' : order.id,
                        'budget'   : 100
                      },
                      {
                        'order_id' : order2.id,
                        'budget'   : 150
                      }
                    ]})
                  .expectStatus(200)
                  .afterJSON(function(){
                      frisby.create('Test accepted status setup')
                        .post(url + '/task/' + task.id + '/accept')
                        .expectStatus(200)
                        .afterJSON(function(){
                          frisby.create('Check accepted status in task')
                            .get(url + '/task/' + task.id)
                            .expectJSON({'accepted' : true})
                            .expectStatus(200)
                            .toss();

                          frisby.create('Remove accepted status')
                            .delete(url + '/task/' + task.id + '/accept')
                            .expectStatus(200)
                            .afterJSON(function(){
                              frisby.create('Check accepted status in task')
                                .get(url + '/task/' + task.id)
                                .expectJSON({'accepted' : false})
                                .expectStatus(200)
                                .toss();
                            })
                            .toss();
                        })
                        .toss();

                      frisby.create('Check updated budget')
                        .get(url + '/task/' + task.id)
                        .expectStatus(200)
                        .expectJSON({'budget' : 250})
                        .toss();

                      frisby.create('Can not delete order, when budget is used for tasks')
                        .delete(url + '/order/' + order.id)
                        .expectStatus(422)
                        .expectJSON({errors:['You can not delete order that is used in task budgeting']})
                        .toss();

                      frisby.create('Can not delete order, when budget is used for tasks')
                        .delete(url + '/order/' + order2.id)
                        .expectStatus(422)
                        .expectJSON({errors:['You can not delete order that is used in task budgeting']})
                        .toss();

                      frisby.create('Check tasks orders')
                        .get(url + '/task/' + task.id)
                        .expectStatus(200)
                        .expectJSON({
                          'orders' : [
                            { 'id' : order.id },
                            { 'id' : order2.id}
                          ]
                        })
                        .toss();

                      frisby.create('Allocatable budget on parent order should NOT decrease, free budget should decrease')
                        .get(url + '/order/' + order.id)
                        .expectStatus(200)
                        .expectJSON({'allocatable_budget' : 1000, 'free_budget' : 900 })
                        .toss();

                      frisby.create('Allocatable budget on parent order should NOT decrease, free budget should decrease')
                        .get(url + '/order/' + order2.id)
                        .expectStatus(200)
                        .expectJSON({'allocatable_budget' : 500, 'free_budget' : 350 })
                        .toss();

                      frisby.create('Check budgets')
                        .get(url + '/task/' + task.id + '/budget')
                        .expectStatus(200)
                        .expectJSON({
                          'budget' : [
                            {
                              'order_id' : order.id,
                              'budget'   : 100
                            },
                            {
                              'order_id' : order2.id,
                              'budget'   : 150
                            }
                          ]})
                        .toss();


                      frisby.create('Create another task')
                        .post(url + '/tasks', {"external_id": "TST-103" })
                        .expectStatus(201)
                        .afterJSON(function(task2){

                            frisby.create('Set task budgets')
                            .post(url + '/task/' + task2.id + '/budget', {'budget' : [
                              {
                                'order_id' : order.id,
                                'budget'   : 100
                              },
                              {
                                'order_id' : order2.id,
                                'budget'   : 150
                              }
                            ]})
                            .expectStatus(200)
                            .toss();

                            frisby.create('Allocatable budget on parent order should NOT decrease, free budget should decrease')
                              .get(url + '/order/' + order.id)
                              .expectStatus(200)
                              .expectJSON({'allocatable_budget' : 1000, 'free_budget' : 800 })
                              .toss();

                            frisby.create('Allocatable budget on parent order should NOT decrease, free budget should decrease')
                              .get(url + '/order/' + order2.id)
                              .expectStatus(200)
                              .expectJSON({'allocatable_budget' : 500, 'free_budget' : 200 })
                              .toss();

                        })
                        .expectStatus(201)
                        .toss();

                      


                      frisby.create('Can not change order team when used for task budgets')
                        .patch(url + '/order/' + order.id, {'team': {'id': 2}})
                        .expectStatus(422)
                         .expectJSON({errors:['Can not change order team - order is used in tasks']})
                         .toss();
                  })
                  .toss();
      })
      .expectStatus(201)
      .toss();

      })
      .toss();
  })
  .toss();


  frisby.create('Missed task external id')
  .post(url + '/tasks',{})
 .expectStatus(422)
 .expectJSON({errors: ['Missing external task ID']})
 .toss();


frisby.create('Correct order creation for unusual team')
  .post(url + '/orders',
       {
          "invoiced_budget": 1500.00,
          "allocatable_budget": 1000.00,
          "name" : "Test",
          "description" : "This is just a test order for SuperClient",
          "team":  {
            "id" : 2
          }
       })
  .expectStatus(201)
  .afterJSON(function(order) {
    frisby.create('Second order creation')
      .post(url + '/orders',
       {
          "invoiced_budget": 2000.00,
          "allocatable_budget": 500.00,
          "name" : "Test2",
          "description" : "This is just a test order for SuperClient",
          "team":  {
            "id" : 1
          }
       })
      .afterJSON(function(order2){
      frisby.create('Correct task creation')
        .post(url + '/tasks', {"external_id": "TST-103" })
        .expectStatus(201)
        .afterJSON(function(task){
          frisby.create('Set task Resolver from different team than we will try to budget')
            .post(url + '/task/' + task.id + '/resolver', {'user_id' : 2})
            .expectStatus(200)
            .afterJSON(function(){
              frisby.create('Check task Resolver')
                .get(url + '/task/' + task.id)
                .expectStatus(200)
                .expectJSON({'resolver' : {'id' : 2}})
                .afterJSON(function(){
                  frisby.create('Set task budgets for incorrect team orders')
                    .post(url + '/task/' + task.id + '/budget', {'budget' : [
                      {
                        'order_id' : order.id,
                        'budget'   : 100
                      },
                      {
                        'order_id' : order2.id,
                        'budget'   : 150
                      }
                    ]})
                    .expectStatus(422)
                    .expectJSON({errors: 
                      [
                        'Orders are created for different teams',
                        'Task resolver is from different team than order' 
                      ]})
                    .afterJSON(function(){
                      frisby.create('Remove resolver from task')
                        .delete(url + '/task/' + task.id + '/resolver')
                        .expectStatus(200)
                        .afterJSON(function(){
                          frisby.create('Check that there is no resolver in task')
                            .get(url + '/task/' + task.id)
                            .expectStatus(200)
                            .expectJSON({'resolver' : {}})
                            .afterJSON(function(){
                              frisby.create('Set task budgets without resolver')
                                .post(url + '/task/' + task.id + '/budget', {'budget' : [
                                  {
                                    'order_id' : order.id,
                                    'budget'   : 100
                                  },
                                  {
                                    'order_id' : order2.id,
                                    'budget'   : 150
                                  }
                                ]})
                                .expectStatus(422)
                                .expectJSON({errors: ['Orders are created for different teams']})
                                .afterJSON(function(){
                                  frisby.create('Set correct task budget')
                                    .post(url + '/task/' + task.id + '/budget', {'budget' : [
                                      {
                                        'order_id' : order2.id,
                                        'budget'   : 300
                                      }]})
                                      .expectStatus(200)
                                      .afterJSON(function(){

                                        frisby.create('Try to change resolver to different team')
                                          .post(url + '/task/' + task.id + '/resolver', {'user_id' : 3})
                                          .expectStatus(422)
                                          .expectJSON({errors: ['Task resolver is from different team than order']})
                                          .toss();

                                        frisby.create('Increase budget from the same order')
                                          .post(url + '/task/' + task.id + '/budget',  {'budget' : [
                                            {
                                              'order_id' : order2.id,
                                              'budget'   : 450
                                            }]})
                                          .expectStatus(200)
                                          .afterJSON(function(){
                                            frisby.create('Can not assign more budget that is available on order')
                                              .post(url + '/task/' + task.id + '/budget',  {'budget' : [
                                                {
                                                  'order_id' : order2.id,
                                                  'budget'   : 501
                                                }]})
                                              .expectStatus(422)
                                              .expectJSON({errors: ['You can not assign more budget than is available on order']})

                                              .afterJSON(function(){
                                                frisby.create('Set task Resolver from different team than we set budget')
                                                  .post(url + '/task/' + task.id + '/resolver', {'user_id' : 2})
                                                  .expectStatus(422)
                                                  .expectJSON({errors:['Task resolver is from different team than order']})
                                                  .toss();
                                              })
                                              .toss();
                                          })
                                          .toss();
                                      })
                                      .toss();
                                  })
                                .toss();
                            })
                            .toss();
                        })
                        .toss();
                    })
                    .toss();

                })
                .toss();

            })
            .toss();
        })
        .toss();
  })
  .toss();
})
.toss();
