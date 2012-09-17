express = require 'express'
routes = require './routes'
stylus = require 'stylus'
fs = require 'fs'
https = require 'https'

run_config = JSON.parse fs.readFileSync __dirname + "/config.json"

CASE_RESULT_TPL = '<test name="#N" executed="#E"><result><success passed="#R" state="100" hasTimedOut="false" /></result></test>'
JENKINS_WS_ROOT＝ ''
app = express()

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

app.get '/ios/config', (req, res)->
  res.send run_config

app.get '/android/config', (req, res)->
  res.send run_config

app.get '/ios/result', (req, res)->
  res_body = ''
  tcm = https.get 'https://tcm.openfeint.com:443//index.php?/miniapi/get_tests/'+run_config.auto_config.run_id + '&key=adfqet87983hiu783flkad09806g98adgk', (response)->
    console.log response.statusCode

    response.on 'data', (d)->
      res_body += d

    response.on 'end', ()->
      tcm_result = JSON.parse res_body
      tcm_cases = tcm_result['tests']
      console.log 'parsing tcm result'
      jenkins_report_xml = '<report name="test_report" categ="CATEGORY_NAME">'

      for tcm_case in tcm_cases
        executed = 'yes'
        if tcm_case['status_id'] in [0, 2, 4]
          executed = 'no'

        result = 'no'
        if tcm_case['status_id'] in [1, 5]
          result = 'yes'

        jenkins_report_xml += CASE_RESULT_TPL.replace('#N', tcm_case['title']).replace('#E', executed).replace('#R', result)

      jenkins_report_xml += '</report>'
      console.log 'generating report for build'

      fs.writeFile JENKINS_WS_ROOT + 'test_report.xml', jenkins_report_xml, (err)->
        console.log 'report done'
        if err
          console.log err
          res.send 'failed'
        res.send 'passed'

  tcm.on 'error', (e)->
    console.error e

  # need generate report in specific format below

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.settings.env