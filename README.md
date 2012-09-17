auto-script
===========

script for starting QA nodejs server for jenkins config/report

## how to start this nodejs server
1. this server is written by coffee-script
2. install nodejs, coffee-script and type 'coffee app.coffee' under
    subserver

## config automation run/suit
1. open subserver/config.js
2. config suite_id and run_id to desire value 
    (we need this two values to fetch tcm suite and push automation result to tcm)
3. start server

## config jenkins workspace root
1. open subserver/config.js
2. config jenkins_ws_root to desire value 
    (we need this path to save test report needed by jenkins)
3. start server