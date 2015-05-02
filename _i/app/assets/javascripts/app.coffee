do($) ->
  authorization = sessionStorage.getItem 'authorization'
  if authorization
    CashFlow.start
      authorization: authorization
      environment: sessionStorage.getItem('env') || 'development'
#      environment: sessionStorage.getItem('env') || 'production'
  else
    window.location.href = '/'
