import constants
from SessionMock import SessionMock, getJWTSecret

def getUserID(index):
  return 'testUserID' + str(index).zfill(3)

def getUserLoginSession(tenantName, index=1, roles=[ constants.DefaultHasAccountRole ]):
  credentials = {
    "userID": getUserID(index=index),
    "roles": roles
  }
  return SessionMock.from_Credentials(credentials, JWTSecretFn=getJWTSecret, tenantName=tenantName).getSession()
