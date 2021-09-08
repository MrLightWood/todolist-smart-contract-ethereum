const todoList = artifacts.require("todoList");

contract('todoList', (accounts) => {
    before(async () => {
        todo = await todoList.deployed(); 
    })

    it("Should return some value", async() => {
        await todo.createTask("Clean up my room", 1662481438);
        await todo.createTask("Watch YouTube", 1662481440);
        await todo.createTask("Say Hi", 1631028600);
        await todo.createTask("Learn German", 1631028600);
        await todo.createTask("Code some contracts", 1631028600);
        
        const tasks = await todo.getTasks();
        
        await todo.editTask(3, "Say Hello", 1631028600);
        await todo.completeTask(3);
        await todo.removeTask(2);
        await todo.failTask(4);
        await todo.completeTask(1);
        await todo.completeTask(5);

        const tasksNew = await todo.getTasks();

        console.log("tasks", tasks);
        console.log("tasksNew", tasksNew);

        assert.equal(1, 1);
    })
})