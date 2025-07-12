// Auth debugging utilities
export function useAuthDebug() {
  const AUTH_LOG_KEY = 'claude-learn-auth-debug'
  const MAX_LOGS = 50
  
  const log = (message, data = {}) => {
    const logs = JSON.parse(localStorage.getItem(AUTH_LOG_KEY) || '[]')
    const entry = {
      timestamp: new Date().toISOString(),
      url: window.location.href,
      hash: window.location.hash,
      message,
      data
    }
    
    logs.unshift(entry)
    if (logs.length > MAX_LOGS) {
      logs.length = MAX_LOGS
    }
    
    localStorage.setItem(AUTH_LOG_KEY, JSON.stringify(logs))
    console.log(`[Auth Debug] ${message}`, data)
  }
  
  const getLogs = () => {
    return JSON.parse(localStorage.getItem(AUTH_LOG_KEY) || '[]')
  }
  
  const clearLogs = () => {
    localStorage.removeItem(AUTH_LOG_KEY)
  }
  
  const printLogs = () => {
    const logs = getLogs()
    console.group('Auth Debug Logs')
    logs.forEach(log => {
      console.log(`${log.timestamp} - ${log.message}`, log.data)
      console.log(`  URL: ${log.url}`)
    })
    console.groupEnd()
  }
  
  return {
    log,
    getLogs,
    clearLogs,
    printLogs
  }
}