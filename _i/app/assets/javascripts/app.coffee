do($) ->
  authorization = sessionStorage.getItem 'authorization'
  if authorization
    CashFlow.start
      authorization: authorization
#      idProject: Number sessionStorage.getItem 'idProject'
#      environment: sessionStorage.getItem 'env' || 'production'
      environment: sessionStorage.getItem 'env' || 'development'
  else
    window.location.href = '/'
