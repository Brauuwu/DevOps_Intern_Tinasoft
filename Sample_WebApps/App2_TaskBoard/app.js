function moveTask(element) {
    const parentId = element.parentElement.id;
    if (parentId === 'todo') {
        document.getElementById('doing').appendChild(element);
        element.style.borderLeftColor = '#3b82f6';
    } else if (parentId === 'doing') {
        document.getElementById('done').appendChild(element);
        element.style.borderLeftColor = '#10b981';
    }
}
function addTask() {
    const titles = ['Fix Ingress rules', 'Update Helm charts', 'Write K8s Secret', 'Debug Kaniko build'];
    const names = ['Hoàng', 'Xuân', 'Hiếu', 'Yến'];
    const task = document.createElement('div');
    task.className = 'task';
    task.onclick = function() { moveTask(this); };
    task.innerHTML = `<div class="task-title">${titles[Math.floor(Math.random()*titles.length)]}</div>
                      <div class="task-meta">Assignee: ${names[Math.floor(Math.random()*names.length)]}</div>`;
    document.getElementById('todo').appendChild(task);
}
