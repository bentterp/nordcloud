#!/bin/bash
#yum -y update
yum -y install git epel-release
yum -y install python2-pip
test -d /home || mkdir /home
cd /home
git clone https://github.com/bentterp/nordcloud.git
cd nordcloud/flask
pip install -r requirements.txt
python db.py
python tests.py
perl -pi -e "s[app.run\(\)][app.run(host='0.0.0.0')]" runserver.py
perl -pi -e "s/SQLALCHEMY_DATABASE_URI.*/SQLALCHEMY_DATABASE_URI = 'mysql:\/\/${db_user}:${db_pass}@${db_host}\/${db_name}'/" notejam/config.py
nohup python runserver.py &>/tmp/nohup.out &
