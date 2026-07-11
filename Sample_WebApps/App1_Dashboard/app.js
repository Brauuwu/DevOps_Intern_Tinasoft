function simulateDeploy() {
    const btn = document.querySelector('button');
    const status = document.getElementById('status-text');
    const dot = document.querySelector('.status-dot');
    
    btn.innerText = 'Deploying...';
    btn.disabled = true;
    status.innerText = 'Syncing';
    dot.style.background = '#eab308';
    dot.style.boxShadow = '0 0 10px #eab308';
    
    setTimeout(() => {
        status.innerText = 'Online';
        dot.style.background = '#22c55e';
        dot.style.boxShadow = '0 0 10px #22c55e';
        document.getElementById('pods').innerText = Math.floor(Math.random() * 10) + 12;
        btn.innerText = 'Simulate Deployment';
        btn.disabled = false;
    }, 2500);
}

setInterval(() => {
    const cpu = document.getElementById('cpu');
    let current = parseInt(cpu.innerText);
    let next = current + (Math.random() > 0.5 ? 1 : -1) * Math.floor(Math.random() * 5);
    if(next < 5) next = 5; if(next > 95) next = 95;
    cpu.innerText = next + '%';
}, 3000);
