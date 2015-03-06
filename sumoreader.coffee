request = require('request')

#.env to be used here
username = 'test@test.com'
password = 'somepass'
url = 'https://api.sumologic.com/api/v1/logs/search'
query_messages = '_collector=somesystem-prd* _source=httpd "INFO"| parse "[* (" as ntype  | parse "--> *sec" as time | num(time) as ntime | timeslice by 1h |  where ntime > 7 | where !(ntype matches "Dont count me title")   | sort by ntime'


query = '_collector=somesystem-prd* _source=httpd "INFO"| parse "[* (" as ntype  | parse "--> *sec" as time | num(time) as ntime | timeslice by 1h |  where ntime > 7 | where !(ntype matches "dont count me title")  | max(ntime), min(ntime), pct(ntime, 90)  by _timeslice | sort by _ntime_pct_90 desc'
qs = require('querystring')
util = require('util')

ISODateString = (d) ->

  pad = (n) ->
    if n < 10 then '0' + n else n

  d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate()) + 'T' + pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes()) + ':' + pad(d.getUTCSeconds())

insp = (obj) ->
  console.log util.inspect(obj, false, null)
  return

from = '2015-01-01T10:00:00'
to = '2015-01-21T17:00:00'
params = 
  q: query_messages
  from: from
  to: to
params = qs.stringify(params)
url = url + '?' + params
request.get url, { 'auth':
  'user': username
  'pass': password
  'sendImmediately': false }, (error, response, body) ->
  if !error and response.statusCode == 200
    json = JSON.parse(body)
    insp json
  else
    console.log '>>> ERrror ' + error + ' code: ' + response.statusCode
  return
