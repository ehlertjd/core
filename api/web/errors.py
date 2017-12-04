
class SciTranException(Exception):
    def __init__(self, msg):
        super(SciTranException, self).__init__(msg)
        # SciTran internal error codes (more specific)
        self.errint = 0
        # Haven't found a case where an Exception is associated with more than one http status code
        self.http_code = 500


class APIAuthProviderException(SciTranException):
    def __init__(self, msg):
        super(APIAuthProviderException, self).__init__(msg)
        self.errint = 1
        self.http_code = 401

# Creating mulitple containers with same id
class APIConflictException(SciTranException):
    def __init__(self, msg):
        super(APIConflictException, self).__init__(msg)
        self.errint = 2
        self.http_code = 409

# For checking database consistency
class APIConsistencyException(SciTranException):
    def __init__(self, msg):
        super(APIConsistencyException, self).__init__(msg)
        self.errint = 3
        self.http_code = 400

# API could not find what was requested
class APINotFoundException(SciTranException):
    def __init__(self, msg):
        super(APINotFoundException, self).__init__(msg)
        self.errint = 4
        self.http_code = 404

class APIPermissionException(SciTranException):
    def __init__(self, msg):
        super(APIPermissionException, self).__init__(msg)
        self.errint = 5
        self.http_code = 403

class APIRefreshTokenException(SciTranException):
    # Specifically alert a client when the user's refresh token expires
    # Requires client to ask for `offline=true` permission to receive a new one
    def __init__(self, msg):

        super(APIRefreshTokenException, self).__init__(msg)
        self.errors = {'core_status_code': 'invalid_refresh_token'}
        self.errint = 6
        self.http_code = 401

class APIReportException(SciTranException):
    def __init__(self, msg=None):
        super(APIReportException, self).__init__(msg)
        self.errint = 7
        self.http_code = 500

# Invalid or missing parameters for a report request
class APIReportParamsException(SciTranException):
    def __init__(self, msg):
        super(APIReportParamsException, self).__init__(msg)
        self.errint = 7
        self.http_code = 500

class APIStorageException(SciTranException):
    def __init__(self, msg):
        super(APIStorageException, self).__init__(msg)
        self.errint = 8
        self.http_code = 500

# User Id not found or disabled
class APIUnknownUserException(SciTranException):
    def __init__(self, msg):
        super(APIUnknownUserException, self).__init__(msg)
        self.errint = 9
        self.http_code = 402

class APIValidationException(SciTranException):
    def __init__(self, errors):

        super(APIValidationException, self).__init__('Validation Error.')
        self.errors = errors
        self.errint = 10
        self.http_code = 422

# json object prepared for storage layer does not match mongo json schema
class DBValidationException(SciTranException):
    def __init__(self, msg):
        super(DBValidationException, self).__init__(msg)
        self.errint = 11
        self.http_code = 500

class FileStoreException(SciTranException):
    def __init__(self, msg):
        super(FileStoreException, self).__init__(msg)
        self.errint = 12
        self.http_code = 400

# File Form for upload requests made by client is incorrect
class FileFormException(SciTranException):
    def __init__(self, msg):
        super(FileFormException, self).__init__(msg)
        self.errint = 12
        self.http_code = 400

# Payload for a POST or PUT does not match input json schema
class InputValidationException(SciTranException):
    def __init__(self, msg):
        super(InputValidationException, self).__init__(msg)
        self.errint = 13
        self.http_code = 400

