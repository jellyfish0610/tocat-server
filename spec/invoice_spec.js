//phase2
//Internal order
//* is a propery
//* becomes expense for team (Income account)
//* mark order as Paid

//TODO phase2 Check that you can not complete suborder order')
//TODO phase2 Check that you CAN complete parent order')


//Zoho books integration.
//  - create books invoice -> set TOCAT invoice as immutable -> set order budgets as immutable

// TODO: Paid not existent order -> 404

// TODO: json=false дает возможность удалить бюджеты POST task/budget с пустым запросом
// Нужно смотреть на параметр budget:[] и проверять его наличие

//TODO:
// resolver = id, accepted=true, paid = false , set paid = true
// accepted&paid = true + Resolver=null, set resolver

// accepted&paid = true, set accepted =false
// accepted&paid = true, set paid =false


var config = require('./config');
var url = config.url;

frisby.create('Correct invoice')
    .post(url + '/invoices',

        {
          "external_id": Math.floor(Math.random() * (99999 - 1)) + 30
        })
    .expectStatus(201)
    .afterJSON(function(invoice){
      frisby.create('Delete invoice')
            .delete(url + '/invoice/' + invoice.id)
            .expectStatus(200)
            .toss();
    })
    .toss();

frisby.create('Correct invoice2')
    .post(url + '/invoices',
      {
          "external_id": Math.floor(Math.random() * (99999 - 1)) + 30
      })
    .expectStatus(201)
    .afterJSON(function(invoice2){
      frisby.create('Correct invoice')
        .post(url + '/invoices',
            {
              "external_id": Math.floor(Math.random() * (99999 - 1)) + 30
            })
        .expectStatus(201)
        .afterJSON(function(invoice){
          frisby.create('Correct order creation')
            .post(url + '/orders',
              {
                "invoiced_budget": 150.00,
                "allocatable_budget": 100.00,
                "name" : "Test",
                "description" : "This is just a test order for SuperClient",
                "team":  {
                  "id" : 1
                }
              })
            .expectStatus(201)
            .afterJSON(function(order){
              frisby.create('Invoice order with inexistent invoice')
                .post(url + '/order/' + order.id + '/invoice', {'invoice_id' : 99999999})
                .expectStatus(422)
                .expectJSON({errors:['Invoice does not exist']})
                .toss();

              frisby.create('Invoice order with correct invoice')
                .post(url + '/order/' + order.id + '/invoice', {'invoice_id' : invoice.id})
                .expectStatus(200)
                .toss();

              frisby.create('Create correct suborder')
                .post(url + '/order/' + order.id + '/suborder', {'allocatable_budget': 50, 'team' : {'id' : 2}, 'name' : 'super order'})
                .expectStatus(201)
                .afterJSON(function(subOrder1) {
                  frisby.create('Create second correct suborder for team3 as parent order')
                    .post(url + '/order/' + order.id + '/suborder', {'allocatable_budget': 30, 'team' : {'id' : 3}, 'name' : 'super order'})
                    .expectStatus(201)
                    .afterJSON(function(subOrder2) {
                       frisby.create('Correct task creation')
                        .post(url + '/tasks', {"external_id": Math.floor(Math.random() * (99999 - 1)) + 30 })
                        .expectStatus(201)
                        .afterJSON(function(task){
                            frisby.create('One more order for team 2')
                              .post(url + '/orders',
                                {
                                  "invoiced_budget": 50.00,
                                  "allocatable_budget": 30.00,
                                  "name" : "Test2",
                                  "description" : "This is just a test order for SuperClient",
                                  "team":  {
                                    "id" : 2
                                  }
                                })
                              .expectStatus(201)
                              .afterJSON(function(order2){
                                  frisby.create('Invoice order2 with correct invoice2')
                                    .post(url + '/order/' + order2.id + '/invoice', {'invoice_id' : invoice2.id})
                                    .expectStatus(200)
                                    .toss();

                                  frisby.create('Suborder can not be invoiced')
                                    .post(url + '/order/' + subOrder1.id + '/invoice', {'invoice_id' : invoice2.id})
                                    .expectStatus(422)
                                    .expectJSON({errors:['Suborder can not be invoiced']})
                                    .toss();

                                  frisby.create('Set task budgets')
                                    .post(url + '/task/' + task.id + '/budget', {'budget' : [
                                      {
                                        'order_id' : subOrder1.id,
                                        'budget'   : 30
                                      }
                                      ,
                                      {
                                        'order_id' : order2.id,
                                        'budget'   : 20
                                      }
                                      ]})
                                    .expectStatus(200)
                                    .toss();

                                  frisby.create('Remove one order from budget')
                                    .post(url + '/task/' + task.id + '/budget', {'budget' : [
                                      {
                                        'order_id' : subOrder1.id,
                                        'budget'   : 30
                                      }
                                      ]})
                                    .expectStatus(200)
                                    .toss();

                                  frisby.create("Check that budget is decreased")
                                    .get(url + '/task/' + task.id)
                                    .expectStatus(200)
                                    .expectJSON({'budget' : 30})
                                    .afterJSON(function(task){
                                      expect(task.orders.length).toEqual(1)
                                    })
                                    .toss();

                                  frisby.create('Remove all orders from budget')
                                    .post(url + '/task/' + task.id + '/budget', {'budget' : [
                                      {

                                      }
                                      ]})
                                    .expectStatus(200)
                                    .toss();

                                  frisby.create("Check that budget is zero")
                                    .get(url + '/task/' + task.id)
                                    .expectStatus(200)
                                    .expectJSON({'budget' : 0})
                                    .afterJSON(function(task){
                                      expect(task.orders.length).toEqual(0)
                                    })
                                    .toss();

                                  frisby.create('Set again task budgets')
                                    .post(url + '/task/' + task.id + '/budget', {'budget' : [
                                      {
                                        'order_id' : subOrder1.id,
                                        'budget'   : 30
                                      }
                                      ,
                                      {
                                        'order_id' : order2.id,
                                        'budget'   : 20
                                      }
                                      ]})
                                    .expectStatus(200)
                                    .toss();

                                  frisby.create('Set task Resolver id=2')
                                    .post(url + '/task/' + task.id + '/resolver', {'user_id' : 2})
                                    .expectStatus(200)
                                    .toss();

                                  frisby.create('Another task creation')
                                    .post(url + '/tasks', {"external_id": Math.floor(Math.random() * (99999 - 1)) + 30 })
                                    .expectStatus(201)
                                    .afterJSON(function(task2){
                                        frisby.create('Set task2 budgets')
                                          .post(url + '/task/' + task2.id + '/budget', {'budget' : [
                                          {
                                            'order_id' : subOrder2.id,
                                            'budget'   : 20
                                          }]})
                                        .expectStatus(200)
                                        .toss();

                                        frisby.create('Set task2 Resolver')
                                          .post(url + '/task/' + task2.id + '/resolver', {'user_id' : 3})
                                          .expectStatus(200)
                                          .toss();

                                        frisby.create('Set invoice paid')
                                          .post(url + '/invoice/' + invoice.id + '/paid')
                                          .expectStatus(200)
                                          .toss();

                                        frisby.create('Check that order is paid')
                                          .get(url + '/order/' + order.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : true})
                                          .toss();

                                        frisby.create('Check that subOrder1 is paid')
                                          .get(url + '/order/' + subOrder1.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : true})
                                          .toss();

                                        frisby.create('Check that subOrder2 is paid')
                                          .get(url + '/order/' + subOrder2.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : true})
                                          .toss();

                                        frisby.create('Check that order2 is not paid')
                                          .get(url + '/order/' + order2.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : false})
                                          .toss();

                                        frisby.create('Check that task is not paid')
                                          .get(url + '/task/' + task.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : false})
                                          .toss();

                                        frisby.create('Check that task2 is paid')
                                          .get(url + '/task/' + task2.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : true})
                                          .toss();

                                        frisby.create('Set invoice2 as paid')
                                          .post(url + '/invoice/' + invoice2.id + '/paid')
                                          .expectStatus(200)
                                          .toss();

                                        frisby.create('Check that order2 is paid')
                                          .get(url + '/order/' + order2.id)
                                          .expectStatus(200)
                                          .expectJSON({'paid' : true})
                                          .toss();

                                        frisby.create('Get balance account of resolver id=2')
                                          .get(url + '/user/2')
                                          .expectStatus(200)
                                          .afterJSON(function(user){
                                            balance_user_2 = user.balance_account_state;

                                              frisby.create('Get balance account of team2')
                                                .get(url + '/team/2')
                                                .expectStatus(200)
                                                .afterJSON(function(team){
                                                  balance_team_2 = team.balance_account_state;

                                                  frisby.create('Set task accepted')
                                                    .post(url + '/task/' + task.id + '/accept')
                                                    .expectStatus(200)
                                                    .toss();

                                                  frisby.create('Check that task is accepted&paid')
                                                    .get(url + '/task/' + task.id)
                                                    .expectStatus(200)
                                                    .expectJSON({'paid' : true, 'accepted' : true})
                                                    .toss();

                                                  frisby.create('Check that task is paid')
                                                    .get(url + '/task/' + task.id)
                                                    .expectStatus(200)
                                                    .expectJSON({'paid' : true})
                                                    .toss();

                                                  frisby.create('Check that resolver id=2 balance is updated')
                                                    .get(url + '/user/2')
                                                    .expectStatus(200)
                                                    .afterJSON(function(user){
                                                      expect(user.balance_account_state).toBe(balance_user_2 + 50);
                                                    })
                                                    .toss();

                                                  frisby.create('Check that team2 balance is updated')
                                                    .get(url + '/team/2')
                                                    .expectStatus(200)
                                                    .afterJSON(function(team){
                                                      expect(team.balance_account_state).toBe(balance_team_2 + 50);
                                                    })
                                                    .toss();

                                                  frisby.create('Get balance account of user4')
                                                    .get(url + '/user/4')
                                                    .expectStatus(200)
                                                    .afterJSON(function(user4){
                                                      balance_user_4 = user4.balance_account_state;

                                                      frisby.create('Get balance account of user3')
                                                        .get(url + '/user/3')
                                                        .expectStatus(200)
                                                        .afterJSON(function(user3){

                                                          balance_user_3 = user3.balance_account_state;

                                                          frisby.create('Get balance account of team3')
                                                            .get(url + '/team/3')
                                                            .expectStatus(200)

                                                            .afterJSON(function(team3){
                                                              balance_team_3 = team3.balance_account_state;

                                                              frisby.create('Set task2 accepted')
                                                                .post(url + '/task/' + task2.id + '/accept')
                                                                .expectStatus(200)
                                                                .toss();

                                                              frisby.create('Check that task2 is accepted&paid')
                                                                .get(url + '/task/' + task2.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'paid' : true, 'accepted' : true})
                                                                .toss();


                                                              frisby.create('Check that user3 balance is updated')
                                                                .get(url + '/user/3')
                                                                .expectStatus(200)
                                                                .afterJSON(function(user){
                                                                  expect(user.balance_account_state).toBe(balance_user_3 + 20);
                                                                })
                                                                .toss();

                                                              frisby.create('Check that team3 balance is updated')
                                                                .get(url + '/team/3')
                                                                .expectStatus(200)
                                                                .afterJSON(function(team){
                                                                  expect(team.balance_account_state).toBe(balance_team_3 + 20);
                                                                })
                                                                .toss();

                                                              frisby.create('Change resolver, but stay in the same team')
                                                                .post(url + '/task/' + task2.id + '/resolver', {'user_id' : 4})
                                                                .expectStatus(200)
                                                                .toss();

                                                              frisby.create('Check that user3 balance is decreased')
                                                                .get(url + '/user/3')
                                                                .expectStatus(200)
                                                                .afterJSON(function(user3){
                                                                  expect(user3.balance_account_state).toBe(balance_user_3);
                                                                })
                                                                .toss();

                                                              frisby.create('Check that team3 balance stays the same')
                                                                .get(url + '/team/3')
                                                                .expectStatus(200)
                                                                .afterJSON(function(team3){
                                                                  expect(team3.balance_account_state).toBe(balance_team_3 + 20);
                                                                })
                                                                .toss();

                                                              frisby.create('Check that user4 balance is increased')
                                                                .get(url + '/user/4')
                                                                .expectStatus(200)
                                                                .afterJSON(function(user4){
                                                                  expect(user4.balance_account_state).toBe(balance_user_4 + 20);
                                                                })
                                                                .toss();

                                                              frisby.create('Unset resolver from task2')
                                                                .delete(url + '/task/' + task2.id + '/resolver')
                                                                .expectStatus(200)
                                                                .toss();

                                                              frisby.create('Check no resolver for task2')
                                                                .get(url + '/task/' + task2.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'resolver' : {}})
                                                                .toss();

                                                              frisby.create('Check that user4 balance is decreased')
                                                                .get(url + '/user/4')
                                                                .expectStatus(200)
                                                                .afterJSON(function(user){
                                                                  expect(user.balance_account_state).toBe(balance_user_4);
                                                                })
                                                                .toss();

                                                              frisby.create('Check that team3 balance is decreased')
                                                                .get(url + '/team/3')
                                                                .expectStatus(200)
                                                                .afterJSON(function(team){
                                                                  expect(team.balance_account_state).toBe(balance_team_3);
                                                                })
                                                                .toss();

                                                              frisby.create('Set invoice unpaid')
                                                                .delete(url + '/invoice/' + invoice.id + '/paid')
                                                                .expectStatus(200)
                                                                .toss();

                                                              frisby.create('Parent order is unpaid')
                                                                .get(url + '/order/' + order.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'paid' : false})
                                                                .toss();

                                                              frisby.create('Suborder1 is unpaid')
                                                                .get(url + '/order/' + subOrder1.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'paid' : false})
                                                                .toss();

                                                              frisby.create('suborder2 is unpaid')
                                                                .get(url + '/order/' + subOrder2.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'paid' : false})
                                                                .toss();

                                                              frisby.create('Task1 is unpaid')
                                                                .get(url + '/task/' + task.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'paid' : false})
                                                                .toss();

                                                              frisby.create('Task2 is unpaid')
                                                                .get(url + '/task/' + task2.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'paid' : false})
                                                                .toss();

                                                              frisby.create('Task1 is still accepted')
                                                                .get(url + '/task/' + task.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'accepted' : true})
                                                                .toss();

                                                              frisby.create('Task2 is still accepted')
                                                                .get(url + '/task/' + task2.id)
                                                                .expectStatus(200)
                                                                .expectJSON({'accepted' : true})
                                                                .toss();


                                                              frisby.create('Delete used invoice is not allowed')
                                                                .delete(url + '/invoice/' + invoice.id)
                                                                .expectStatus(422)
                                                                .expectJSON({errors:['Invoice is linked to orders']})
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
    })
    .toss();

frisby.create('Correct additional invoice')
 .post(url + '/invoices',
      {
        "external_id": Math.floor(Math.random() * (99999 - 1)) + 30
      })
 .expectStatus(201)
 .afterJSON(function(invoice2){
    frisby.create('Correct invoice creation')
    .post(url + '/invoices',
      {
        "external_id": Math.floor(Math.random() * (99999 - 1)) + 30
      })
    .expectStatus(201)
    .afterJSON(function(invoice){
      frisby.create('Correct new order creation')
        .post(url + '/orders',
          {
            "invoiced_budget": 150.00,
            "allocatable_budget": 100.00,
            "name" : "Test",
            "description" : "This is just a test order for SuperClient",
            "team":  {
              "id" : 1
            }
          })
        .expectStatus(201)
        .afterJSON(function(order){

          frisby.create('Can not set order as paid directly')
            .post(url + '/order/' + order.id + '/paid')
            .expectStatus(404)
            .toss();

          frisby.create('Invoice order')
            .post(url + '/order/' + order.id + '/invoice', {'invoice_id' : invoice.id})
            .expectStatus(200)
            .toss();

              frisby.create("Set invoice as paid")
                .post(url + '/invoice/' + invoice.id + '/paid')
                .expectStatus(200)
                .toss();

                frisby.create('Can not change invoice for already paid order')
                  .post(url + '/order/' + order.id + '/invoice', {'invoice_id' : invoice2.id})
                  .expectStatus(422)
                  .expectJSON({errors:['Order is already paid, can not change invoice']})
                  .toss();

                frisby.create('Can not delete order from paid invoice')
                  .delete(url + '/order/' + order.id + '/invoice')
                  .expectStatus(422)
                  .expectJSON({errors:['Order is already paid, can not unlink it from invoice']})
                  .toss();

                frisby.create('Can not delete already paid invoice')
                  .delete(url + '/order/' + order.id)
                  .expectStatus(422)
                  .expectJSON({errors:['Can not delete already paid invoice']})
                  .toss();

                frisby.create('Can not update invoiced budget of paid order')
                  .patch(url + '/order/' + order.id, {'allocatable_budget': 200, 'invoiced_budget' : 300})
                  .expectStatus(422)
                  .expectJSON({errors:['Order is already paid, can not update invoiced budget']})
                  .toss();

                frisby.create('CAN update allocated budget of paid order')
                  .patch(url + '/order/' + order.id, {'allocatable_budget': 90 })
                  .expectStatus(200)
                  .toss();

                frisby.create("Check new allocatable budget")
                  .get(url + '/order/' + order.id)
                  .expectStatus(200)
                  .expectJSON({'allocatable_budget' : 90.00, 'invoiced_budget' : 150.00})
                  .toss();

                frisby.create("One more order")
                  .post(url + '/orders',
                    {
                      "invoiced_budget": 100.00,
                      "allocatable_budget": 80.00,
                      "name" : "Test2",
                      "description" : "This is just a test order for SuperClient",
                      "team":  {
                        "id" : 2
                      }
                    })
                  .expectStatus(201)
                  .afterJSON(function(order2){
                    frisby.create('Can not link order to already paid invoice')
                      .post(url + '/order/' + order2.id + '/invoice', {'invoice_id' : invoice.id})
                      .expectStatus(422)
                      .expectJSON({errors:['Invoice is already paid, can not use it for new order']})
                      .toss();
                  })
                  .toss();
            })
            .toss();
        })
        .toss();
    })
    .toss();
