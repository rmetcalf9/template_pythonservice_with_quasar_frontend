/*
File for the endpoint identification process code
*/
import axios from 'axios'

function startEndpointIdentificationProcess ({ endpoint, callback, rjmStateChange }) {
  const initialEndpointInfo = rjmStateChange.getFromState('getEndpointInfo')(endpoint)
  if (initialEndpointInfo.endpointIdentificationProcessState !== 0) return
  rjmStateChange.executeAction('setEndpointIdentificationProcessState', { endpoint, newState: 1 })

  const callbackInternal = {
    ok: function ({ serverinfoResponse, endpoint, sucessfulapiprefix }) {
      // // console.log('Success API response recieved')
      // // console.log('startEndpointIdentificationprocess Success', serverinfoResponse, sucessfulapiprefix)
      rjmStateChange.executeAction('finishedEndpointIdentificationProcess', {
        endpoint,
        sucessfulapiprefix,
        serverInfo: serverinfoResponse.data
      })
      const endpointInfo = rjmStateChange.getFromState('getEndpointInfo')(endpoint)
      if (typeof (endpointInfo.finishEndPointIdentificationHook) !== 'undefined') {
        const param = {
          serverInfo: endpointInfo.serverInfo,
          apiPrefix: endpointInfo.apiPrefix
        }
        endpointInfo.finishEndPointIdentificationHook(param)
      }
      callback.ok({ serverinfoResponse, endpoint, sucessfulapiprefix })
    },
    error: function (response) {
      // Need to watch for infinite loop
      console.log('EndpointIdentificationprocess FAILED for', endpoint, ' with response ', response)
      rjmStateChange.executeAction('setEndpointIdentificationProcessState', { endpoint, newState: 0 })
      callback.error(response)
    }
  }
  tryToReadServerInfoFromAllThesePossibleAPIPrefixes({
    possibleApiPrefixes: initialEndpointInfo.apiPrefixIdentificationProcessConfig.possibleApiPrefixes,
    callback: callbackInternal,
    endpoint
  })
}

function getUrlToCall (prefixRecord, apiPath, orveridePublicPrivatePart) {
  // apitype can be either 'public' or 'private' and it's the kong endpoint part of the url
  let apiTypeToUse = prefixRecord.apitype
  if (typeof (orveridePublicPrivatePart) !== 'undefined') {
    apiTypeToUse = orveridePublicPrivatePart
  }
  if (prefixRecord.connectingthroughnginx) {
    return prefixRecord.prefix + '/' + apiTypeToUse + '/api' + apiPath
  }
  return prefixRecord.prefix + '/api/' + apiTypeToUse + apiPath
}

function tryToReadServerInfoFromAllThesePossibleAPIPrefixes ({ possibleApiPrefixes, callback, endpoint }) {
  if (possibleApiPrefixes.length === 0) {
    callback.error('Fail')
    return
  }
  const prefixToTry = possibleApiPrefixes.shift()

  const config = {
    method: 'GET',
    url: getUrlToCall(prefixToTry, '/info/serverinfo')
  }
  console.log('Trying to reach API at ' + config.url)
  axios(config).then(
    (response) => {
      // TODO Considercheck that this server info is for this service
      //   might be helpful when I run mutiple services locally
      console.log('SUCCESS! - reached api at ' + config.url)
      callback.ok({
        serverinfoResponse: response,
        endpoint,
        sucessfulapiprefix: prefixToTry
      })
    },
    (response) => {
      console.log('FAILED')
      tryToReadServerInfoFromAllThesePossibleAPIPrefixes({ possibleApiPrefixes, callback, endpoint })
    }
  )
}

export default {
  startEndpointIdentificationProcess
}
