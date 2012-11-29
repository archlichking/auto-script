express = require 'express'
routes = require './routes'
stylus = require 'stylus'
fs = require 'fs'
https = require 'https'


TCM_KEY = "adfqet87983hiu783flkad09806g98adgk"
routes = JSON.parse fs.readFileSync __dirname + "/router.json"

CASE_RESULT_TPL = '<test name="#N" executed="#E"><result><success passed="#R" state="100" hasTimedOut="false" /></result></test>'
app = express()

# Helper

SLog = (level, text)->
  switch level
    when 'info' then console.info('[' + Date() + '] ==> ' + text)
    when 'error' then console.error('[' + Date() + '] ==> ' + text)
    when 'log' then console.log('[' + Date() + '] ==> ' + text)
    else console.log('[' + Date() + '] ==> ' + text)

# Configuration

app.configure ()->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + '/public')
  app.use stylus.middleware({src:__dirname + '/public'})
  app.use app.router

app.configure 'development', ()->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure 'production', ()->
  app.use express.errorHandler()

# Routers

deliver_router = (path, router) ->
  if path.indexOf('config') > 0
    app.get path, (req, res) ->
      SLog 'info', '------------- http get request receiving ----------------------'
      SLog 'info',  req.ip + ' is requesting ' + path

      if req.param('key') isnt TCM_KEY
        SLog 'error', 'tcm key not match, warning caller'
        res.send 'nil'
      else
        SLog 'info', 'responding'
        res.send JSON.stringify(router)

  else if path.indexOf('report') > 0 and path.indexOf('ios') > 0
    app.post path, (req, res)->
      r = 
        status : '0'
        message : 'passed'

      SLog 'info', '------------- http post request receiving ----------------------'
      SLog 'info', req.ip + ' is requesting report generation'

      if req.param('key') isnt TCM_KEY
        SLog 'error', 'tcm key not match, warning caller'
        r.status = 0
        r.message = 'don\'t do harm to little subserver, you need a valid key :-<'
        res.send r

      else 
        res_body = ''
        tcm = https.get 'https://tcm.openfeint.com:443/index.php?/miniapi/get_tests/'+ router.run_id + '&key=' + TCM_KEY, (response)->
          SLog 'info', 'tcm responds http ' + response.statusCode

          response.on 'data', (d)->
            res_body += d

          response.on 'end', ()->
            tcm_result = JSON.parse res_body

            tcm_cases = tcm_result['tests']
            SLog 'info', 'parsing tcm result'
            jenkins_report_xml = '<report name="test_report" categ="CATEGORY_NAME">'

            for tcm_case in tcm_cases
              executed = 'yes'
              if tcm_case['status_id'] in [0, 2, 4]
                executed = 'no'

              result = 'no'
              if tcm_case['status_id'] in [1]
                result = 'yes'

              jenkins_report_xml += CASE_RESULT_TPL.replace('#N', tcm_case['title']).replace('#E', executed).replace('#R', result)

            jenkins_report_xml += '</report>'
            SLog 'info', 'generating report for build'



            fs.writeFile router.jenkins_ws_root + 'test_report.xml', jenkins_report_xml, (err)->
              SLog 'info', 'report done'
              if err
                console.error err
                r.status = 0
                r.message = 'error occurs while writing report to hard disk'
              else
                r.status = 1
                r.message = 'report generated'
              res.send r

        tcm.on 'error', (e)->
          SLog 'error', e
  else
    app.get path, (req, res) ->
      res.send "no router"

for path, router of routes
  console.log path
  console.log router
  deliver_router path, router

###
  get params:
    key      : tcm-key
    platform : platform (ios/android) who is requesting automation config
###
app.get '/config', (req, res)->
  SLog 'info',  '------------- begin config ----------------------'
  SLog 'info',  req.ip + ' is requesting config'
  if req.param('key') isnt TCM_KEY
    SLog 'error', 'tcm key not match, warning caller'
    res.send 'nil'

  else if req.param('platform') not in ['ios', 'android']
    SLog 'error', 'platform missing or not equals to ios or android'
    res.send 'nil'

  else
    SLog 'info', 'responding'
    r = 
      auto_config :
        is_create_run : run_config.auto_config.is_create_run
        suite_id : run_config.auto_config.suite_id
        run_id :  run_config.auto_config.run_id[req.param('platform')]
    res.send JSON.stringify(r)

###
  post params:
    key       : tcm-key
    runId     : tcm run id
    reportDir : location to generate report
###
app.post '/report', (req, res)->
  r = 
    status : '0'
    message : 'passed'

  SLog 'info', '------------- begin report ----------------------'
  SLog 'info', req.ip + ' is requesting report generation'

  if req.param('key') isnt TCM_KEY
    SLog 'error', 'tcm key not match, warning caller'
    r.status = 0
    r.message = 'don\'t do harm to little subserver, you need a valid key to do so :-<'
    res.send r

  else if not req.param('runId') or not req.param('reportDir')
    SLog 'error', 'runID or reportDir is nil'
    r.status = 0
    r.message = 'don\'t do harm to little subserver, you need a valid runId or reportDir :-<'
    res.send r

  else
    res_body = ''
    tcm = https.get 'https://tcm.openfeint.com:443//index.php?/miniapi/get_tests/'+req.param('runId') + '&key=' + req.param('key'), (response)->
      SLog 'info', 'tcm responds http ' + response.statusCode

      response.on 'data', (d)->
        res_body += d

      response.on 'end', ()->
        tcm_result = JSON.parse res_body

        tcm_cases = tcm_result['tests']
        SLog 'info', 'parsing tcm result'
        jenkins_report_xml = '<report name="test_report" categ="CATEGORY_NAME">'

        if tcm_cases
          for tcm_case in tcm_cases
            executed = 'yes'
            if tcm_case['status_id'] in [0, 2, 4]
              executed = 'no'

            result = 'no'
            if tcm_case['status_id'] in [1]
              result = 'yes'

            jenkins_report_xml += CASE_RESULT_TPL.replace('#N', tcm_case['title']).replace('#E', executed).replace('#R', result)

        jenkins_report_xml += '</report>'
        SLog 'info', 'generating report for build'



        fs.writeFile req.param('reportDir') + 'test_report.xml', jenkins_report_xml, (err)->
          SLog 'info', 'report done'
          if err
            console.error err
            r.status = 0
            r.message = 'error occurs while writing report to hard disk'
          else
            r.status = 1
            r.message = 'report generated'
          res.send r

    tcm.on 'error', (e)->
      SLog 'error', e

  # need generate report in specific format below

app.listen 3000
SLog 'info', 'Express server listening on port 3000'
