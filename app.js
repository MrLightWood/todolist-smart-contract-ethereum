const Web3 = require('web3');
const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');

const mnemonic = fs.readFileSync("./nogit-files/.secret").toString().trim();
//const provider = new HDWalletProvider(mnemonic, `http://localhost:7545`)
const provider = new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/<YOUR-KEY>`)
const web3 = new Web3(provider);
const abiArray = JSON.parse(fs.readFileSync('./build/contracts/todoList.json', 'utf-8'));

const contractAddress = "<Contract-Address>"
const senderAddress = "<Sender-Address>"
const contractOptions = { from: senderAddress };
const contract = new web3.eth.Contract(abiArray.abi, contractAddress);

const createTask = async (description, deadline) => {
  let date = new Date(deadline);
  _deadline = date.getTime();

  await contract.methods.createTask(description, _deadline)
    .send(contractOptions, function (err, res) {
      if (err) {
          console.log("An error occured", err)
        return
      }
      console.log("Hash of the transaction: " + res)
    })
}

const editTask = async (id, description, deadline) => {
  let date = new Date(deadline);
  _deadline = date.getTime;
  
  await contract.methods.editTask(id, description, _deadline)
    .send(contractOptions, function (err, res) {
      if (err) {
          console.log("An error occured", err)
        return
      }
      console.log("Hash of the transaction: " + res)
    })
}

const removeTask = async (id) => {
  await contract.methods.removeTask(id)
    .send(contractOptions, function (err, res) {
      if (err) {
          console.log("An error occured", err)
        return
      }
      console.log("Hash of the transaction: " + res)
    })
}

const completeTask = async (id) => {
  await contract.methods.completeTask(id)
    .send(contractOptions, function (err, res) {
      if (err) {
          console.log("An error occured", err)
        return
      }
      console.log("Hash of the transaction: " + res)
    })
}

const failTask = async (id) => {
  await contract.methods.failTask(id)
    .send(contractOptions, function (err, res) {
      if (err) {
          console.log("An error occured", err)
        return
      }
      console.log("Hash of the transaction: " + res)
    })
}

const getTaskIDs = async () => {
  await contract.methods.getTaskIDs()
  .call(function (err, res) {
    if (err) {
      console.log("An error occured", err)
      return
    }
    console.log("getTaskIDs", res);
  })
}

const getTasks = async () => {
  await contract.methods.getTasks()
  .call(function (err, res) {
    if (err) {
      console.log("An error occured", err)
      return
    }

    for(let i=0; i < res.length; i++) {
      console.log({
        id: res[i].id,
        owner: res[i].owner,
        description: res[i].description,
        deadline: res[i].deadline,
        progress: getProgress(res[i].progress),
      })
    }

  })
}

const getProgress = (progress) => {
  switch(progress) {
    case '0':
      return "ONGOING";
    case '1':
      return "COMPLETED";
    case '2':
      return "LATE";
    case '3':
      return "FAILED";
  }
}

const getTasksSize = async () => {
  await contract.methods.getTasksSize()
  .call(function (err, res) {
    if (err) {
      console.log("An error occured", err)
      return
    }
    console.log("getTasksSize: ", res)
  })
}

const getTaskByID = async (id) => {
  await contract.methods.getTaskByID(id)
  .call(function (err, res) {
    if (err) {
      console.log("An error occured", err)
      return
    }
    console.log("getTaskByID: ", {
      id: res.id,
      owner: res.owner,
      description: res.description,
      deadline: res.deadline,
      progress: getProgress(res.progress),
    });
  })
}

// DEADLINE FORMAT -> "04/12/2021 07:00"

(async() => {
  try {
    await createTask("Watch YouTube", "04/12/2021 07:00");
    await createTask("Watch Netflix", "04/13/2021 10:00");
    await createTask("Watch Netflix", "04/13/2021 10:00");
    await removeTask(2);
    await completeTask(1);
    await completeTask(3);
    await getTasks();
    await getTaskIDs();
  } catch (err){
    console.log(err);
  }
})()
return;
