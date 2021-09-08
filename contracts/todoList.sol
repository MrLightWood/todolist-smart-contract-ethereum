// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

contract todoList {
    enum TaskProgress {ONGOING, COMPLETED, LATE, FAILED}

    struct Task {
        uint256 id;
        address owner; //Owner of the task
        string description; //Description of the task
        uint256 deadline; //Epoch Unix time
        TaskProgress progress; //Progress
    }

    uint256 private _tasksCount; // Tracks ID of last task. Counting starts from 1
    mapping (address => uint256[]) private _accountTasks; // Used to point array of Task IDs that user has
    mapping (uint256 => Task) private _tasks; // Maps taskID to the corresponding task

    // <============================ TODOLIST PUBLIC FUNCTIONS ===========================>

    function createTask(string memory _description, uint256 _deadline) public returns (bool) {
        address creator = msg.sender; // Sender address is called creator because he/she initiates new Task Creation
        require(_deadline > block.timestamp, "todoList: Deadline value must be higher than current time"); // Check if Deadline for task is set for the future time
        bytes memory tempEmptyStringTest = bytes(_description); // Convert string to bytes to check the its length
        require(tempEmptyStringTest.length > 0, "todoList: Description value cannot be empty"); // Check if string bytes is higher than zero (not empty)

        uint256 newTaskID = ++_tasksCount;
        uint256[] storage taskIDs = _accountTasks[creator];

        Task memory newTask;
        newTask.id = newTaskID;
        newTask.owner = creator;
        newTask.description = _description;
        newTask.deadline = _deadline;
        newTask.progress = TaskProgress.ONGOING;
        _tasks[newTaskID] = newTask;

        taskIDs.push(newTaskID);
        _accountTasks[creator] = taskIDs;

        emit TaskCreated(creator, newTaskID, _description, _deadline, TaskProgress.ONGOING);

        return true;
    }

    function editTask(uint256 _id, string memory _description, uint256 _deadline) public returns (bool) {
        checkTaskExistence(_id);
        
        address editor = msg.sender;
        address owner = _tasks[_id].owner;

        require(editor == owner, "todoList: Task can only be edited by its creator");
        require(_deadline > block.timestamp, "todoList: Deadline value must be higher than current time"); // Check if Deadline for task is set for the future time
        
        bytes memory tempEmptyStringTest = bytes(_description); // Convert string to bytes to check the its length
        require(tempEmptyStringTest.length > 0, "todoList: Description value cannot be empty"); // Check if string bytes is higher than zero (not empty)

        _tasks[_id].description = _description;
        _tasks[_id].deadline = _deadline;

        emit TaskEdited(editor, _id, _description, _deadline, _tasks[_id].progress);

        return true;
    }

    function failTask(uint256 _id) public returns (bool) {
        checkTaskExistence(_id);

        address editor = msg.sender;
        address owner = _tasks[_id].owner;

        require(editor == owner, "todoList: Task's progress can be set to 'FAILED' only by the owner");
        require(_tasks[_id].progress != TaskProgress.FAILED, "todoList: This task has already been failed");

        _tasks[_id].progress = TaskProgress.FAILED;

        emit TaskFailed(editor, _id, _tasks[_id].progress);

        return true;
    }

    function completeTask(uint256 _id) public returns (bool) {
        checkTaskExistence(_id);

        address editor = msg.sender;
        address owner = _tasks[_id].owner;

        require(editor == owner, "todoList: Task's progress completion function can only be executed by owner");
        require(_tasks[_id].progress != TaskProgress.COMPLETED, "todoList: This task has already been completed");
        require(_tasks[_id].progress != TaskProgress.LATE, "todoList: This task has already been completed");

        if(_tasks[_id].deadline >= block.timestamp) {
            _tasks[_id].progress = TaskProgress.COMPLETED;
        } else {
            _tasks[_id].progress = TaskProgress.LATE;
        }

        emit TaskCompleted(editor, _id, _tasks[_id].progress);

        return true;
    }

    function removeTask(uint256 _id) public returns (bool) {
        checkTaskExistence(_id);

        address editor = msg.sender;
        address owner = _tasks[_id].owner;
        require(editor == owner, "todoList: Task can only be removed by its creator");
        uint256 tasksLength = _accountTasks[editor].length;
        delete _tasks[_id];         

        for(uint i=0; i < tasksLength; i++) {
            if(_accountTasks[editor][i] == _id) {
                delete _accountTasks[editor][i];
                _accountTasks[editor][i] = _accountTasks[editor][tasksLength-1];
                _accountTasks[editor].pop();
                tasksLength--;
            }
        }

        emit TaskRemoved(editor, _id);

        return true;
    }

    // <============================ TODOLIST PUBLIC GETTER FUNCTIONS ===========================>

    function getTaskIDs() public view returns(uint256[] memory) {
        address _address = msg.sender;
        return _accountTasks[_address];
    }

    function getTasks() public view returns (Task[] memory) {
        address _address = msg.sender;

        uint accountTasksNumber = _accountTasks[_address].length;
        Task[] memory tasks = new Task[](accountTasksNumber);

        for(uint i = 0; i < accountTasksNumber; i++) {
            tasks[i] = _tasks[_accountTasks[_address][i]];
        }
        
        return tasks;
    }

    function getTasksSize() public view returns (uint) {
        return _accountTasks[msg.sender].length;
    }

    function getTaskByID(uint256 _id) public view returns(Task memory) {
        return _tasks[_id];
    }

    // <============================ TODOLIST EVENTS ===========================>

    event TaskCreated(address indexed creator, uint256 indexed id, string description, uint256 deadline, TaskProgress progress);

    event TaskEdited(address indexed owner, uint256 indexed id, string description, uint256 deadline, TaskProgress progress);

    event TaskRemoved(address indexed owner, uint256 indexed id);

    event TaskCompleted(address indexed owner, uint256 indexed id, TaskProgress progress);

    event TaskFailed(address indexed owner, uint256 indexed id, TaskProgress progress);

    // <============================ TODOLIST INTERNAL FUNCTIONS ===========================>
    
    function checkTaskExistence(uint256 _id) internal view returns (bool){
        if(_tasks[_id].owner == address(0)) {
            revert("The task of provided ID does not exist");
        }
        return true;
    }
}