const alerts = {
    success: { icon: '✅', title: 'Deployment Successful', msg: 'ArgoCD has synced the latest image to the production cluster.' },
    warning: { icon: '⚠️', title: 'Resource Warning', msg: 'Node worker-02 is operating at 92% memory capacity.' },
    danger: { icon: '🚨', title: 'Critical Failure', msg: 'Pod backend-api-5c9d in default namespace crashed with Exit Code 1.' }
};

function showToast(type) {
    const container = document.getElementById('toastContainer');
    const data = alerts[type];
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <div class="toast-icon">${data.icon}</div>
        <div class="toast-content">
            <h4>${data.title}</h4>
            <p>${data.msg}</p>
        </div>
    `;
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.add('fade-out');
        setTimeout(() => toast.remove(), 400);
    }, 4000);
}
