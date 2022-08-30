# Used for testing
# and for inserting test data

import constants
from appObj import appObj

from datetime import timedelta
import copy
import jwt
from base64 import b64decode
import json

# normally in saas_user_management
APIAPP_JWT_TOKEN_TIMEOUT = 999

def getJWTSecretFromAppObj():
  return appObj.APIAPP_JWTSECRET

def getJWTSecret():
  return getJWTSecretFromAppObj()

def generateJWTToken(appObj, userDict, secret, key, personGUID, currentlyUsedAuthProviderGuid, currentlyUsedAuthKey):
  expiryTime = appObj.getCurDateTime() + timedelta(seconds=int(APIAPP_JWT_TOKEN_TIMEOUT))
  if secret is None:
    raise Exception("Trying to generate a JWT Token without a secret being set")
  if key is None:
    raise Exception("Trying to generate a JWT Token without a key being set")


  JWTDict = copy.deepcopy(userDict)
  JWTDict['authedPersonGuid'] = personGUID
  JWTDict['currentlyUsedAuthProviderGuid'] = currentlyUsedAuthProviderGuid
  JWTDict['currentlyUsedAuthKey'] = currentlyUsedAuthKey
  JWTDict['iss'] = key
  JWTDict['exp'] = expiryTime
  ## JWTDict = appObj.gateway.enrichJWTClaims(JWTDict)
  encodedJWT = jwt.encode(JWTDict, b64decode(secret), algorithm='HS256')

  # print("generateJWTToken", expiryTime)

  return {'JWTToken': encodedJWT.decode('utf-8'), 'TokenExpiry': expiryTime.isoformat() }


def generateJWTTokenFromUserDict(userDict, JWTSecretFn):
  return generateJWTToken(
    appObj,
    userDict,
    JWTSecretFn(),
    userDict['UserID'],
    'DummypersonGUID',
    'DummyCurrentlyAuthedGUID',
    'DummyAuthKey'
  )['JWTToken']

def makeJWTTokenWithMasterTenantRoles(roles, UserID, JWTSecretFn, tenantName):
  userDict = {
    "UserID": UserID,
    "TenantRoles": { tenantName: roles}
  }
  return generateJWTTokenFromUserDict(userDict, JWTSecretFn)


class SessionMock():
  userID = None
  JWTToken = None
  roles = None
  tenantName = None
  def __init__(self, userID, roles, JWTSecretFn, frmSesisonJWTToken, tenantName):
    if frmSesisonJWTToken is None:
      frmSesisonJWTToken = makeJWTTokenWithMasterTenantRoles(roles, userID, JWTSecretFn, tenantName)
    self.userID = userID
    self.JWTToken = frmSesisonJWTToken
    self.roles = roles
    self.tenantName = tenantName

  @classmethod
  #def from_Credentials(cls, credentials, JWTSecretFn=getJWTSecret) -> 'SessionMock':
  def from_Credentials(cls, credentials, JWTSecretFn, tenantName) -> 'SessionMock':
  	return cls(credentials["userID"], credentials["roles"], JWTSecretFn, frmSesisonJWTToken=None, tenantName=tenantName)

  @classmethod
  def from_Session(cls, session, JWTSecretFn=getJWTSecret) -> 'SessionMock':
  	return cls(session["loggedInAs"], session["roles"], JWTSecretFn, frmSesisonJWTToken=session["jwtToken"], tenantName=session["tenantName"])

  def getSession(self):
    return {
      "loggedInAs": self.userID,
      "roles": self.roles,
      "jwtToken": self.JWTToken,
      "tenantName": self.tenantName
    }

  def getJWTToken(self):
    return self.JWTToken
