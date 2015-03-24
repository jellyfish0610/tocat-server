truncate accounts;
truncate task_orders;
truncate tasks;
truncate transactions;
truncate users;
truncate teams;
truncate roles;

insert into roles values (1, "Manager", now(), now());
insert into roles values (2, "Developer", now(), now());
insert into teams values (1, "OpsWay1", now(), now());
insert into teams values (2, "OpsWay2", now(), now());
insert into teams values (3, "OpsWay3", now(), now());

insert into users values(1, "Dev1", 'dev1', 1, 50, now(), now(), 2);
insert into users values(2, "Dev2", 'dev2', 2, 60, now(), now(), 2);
insert into users values(3, "Dev3", 'dev3', 3, 70, now(), now(), 2);
insert into users values(4, "Dev4", 'dev4', 3, 80, now(), now(), 2);

insert into accounts values(1, 'balance', now(), now(), 1, 'Team');
insert into accounts values(2, 'balance', now(), now(), 2, 'Team');
insert into accounts values(3, 'balance', now(), now(), 3, 'Team');
insert into accounts values(4, 'payment', now(), now(), 1, 'Team');
insert into accounts values(5, 'payment', now(), now(), 2, 'Team');
insert into accounts values(6, 'payment', now(), now(), 3, 'Team');
insert into accounts values(7, 'balance', now(), now(), 1, 'User');
insert into accounts values(8, 'balance', now(), now(), 2, 'User');
insert into accounts values(9, 'balance', now(), now(), 3, 'User');
insert into accounts values(10, 'balance', now(), now(), 4, 'User');
insert into accounts values(11, 'payment', now(), now(), 1, 'User');
insert into accounts values(12, 'payment', now(), now(), 2, 'User');
insert into accounts values(13, 'payment', now(), now(), 3, 'User');
insert into accounts values(14, 'payment', now(), now(), 4, 'User');