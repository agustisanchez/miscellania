create database geogrep_location_dev default charset 'utf8';
create database geogrep_location_devtest default charset 'utf8';
create database geogrep_location_ci default charset 'utf8';
create user geogrepUser identified by 'geogrepMy5ql';
grant all privileges on geogrep_location_dev.* to geogrepUser;
grant all privileges on geogrep_location_devtest.* to geogrepUser;
grant all privileges on geogrep_location_ci.* to geogrepUser;
create database indextool_dev default charset 'utf8';
create database indextool_devtest default charset 'utf8';
create database indextool_ci default charset 'utf8';
create user indextool identified by 'indextool';
grant all privileges on indextool_dev.* to indextool;
grant all privileges on indextool_devtest.* to indextool;
grant all privileges on indextool_ci.* to indextool;


