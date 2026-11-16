/*
This file contains functions to call the api client backends.
*/
import { saasServiceName } from './router/routes.js'
import { useUserManagementClientStoreStore } from 'stores/saasUserManagementClientStore'

// const authedStoreFn = 'callAuthedAPI'
const authedOrAnonStoreFn = 'callAuthedOrAnonAPI'

/*
One entry here for ecery prefix ins the python backend app
 matches prefixes foudn in /services/src/APIs/__init__.py
*/
const apiPrefixes = {
  info: { // baseapp provided endpoint
    endpoint: saasServiceName,
    path: '/info',
    storeFn: authedOrAnonStoreFn, // authedStoreFn or authedOrAnonStoreFn
    orveridePublicPrivatePart: 'public' // public or private
  }
}

function callApi ({
  prefix, // must match prefix from apiPRefixes array
  router,
  path, // : queryString,
  method, // : 'get',
  postdata, // : null,
  callback, // : callback,
  tenantName // optional if undefined not added
}) {
  if (typeof (apiPrefixes[prefix]) === 'undefined') {
    console.log('ERROR invalid prefix provided to callAPI - ', prefix, apiPrefixes)
    return
  }
  let curPath // = undefined
  if (typeof (router) !== 'undefined') {
    curPath = router.currentRoute.value.fullPath
  }
  const getPathFn = function (tenantName, prefix, path) {
    if (typeof (tenantName) === 'undefined') {
      return apiPrefixes[prefix].path + path
    }
    return apiPrefixes[prefix].path + '/' + tenantName + path
  }
  const userManagementClientStore = useUserManagementClientStoreStore()
  userManagementClientStore[apiPrefixes[prefix].storeFn]({
    endpoint: apiPrefixes[prefix].endpoint,
    path: getPathFn(tenantName, prefix, path),
    method,
    postdata,
    callback,
    curpath: curPath,
    orveridePublicPrivatePart: apiPrefixes[prefix].orveridePublicPrivatePart
  })
}

export default {
  callApi
}
