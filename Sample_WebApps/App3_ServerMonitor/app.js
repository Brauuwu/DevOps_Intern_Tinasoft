let intervalId = null;
const terminal = document.getElementById('terminal');
const endpoints = ['/api/v1/users', '/auth/login', '/healthz', '/metrics', '/api/v2/orders'];

function addLog() {
    const isError = Math.random() > 0.85;
    const status = isError ? (Math.random() > 0.5 ? '500' : '404') : '200';
    const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
    const time = new Date().toISOString().split('T')[1].slice(0, -1);
    
    const line = document.createElement('div');
    line.className = `log-line ${isError ? 'error' : ''}`;
    line.innerHTML = `<span class="timestamp">[${time}]</span> HTTP GET ${endpoint} - STATUS ${status} - ${Math.floor(Math.random()*100 + 10)}ms`;
    
    terminal.appendChild(line);
    terminal.scrollTop = terminal.scrollHeight;
    
    if(terminal.children.length > 50) terminal.removeChild(terminal.firstChild);
}

function startLogs() { if(!intervalId) intervalId = setInterval(addLog, 400); }
function stopLogs() { clearInterval(intervalId); intervalId = null; }
function clearLogs() { terminal.innerHTML = ''; }

// Start automatically
startLogs();
