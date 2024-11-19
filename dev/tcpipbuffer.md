# Setting up a TCP/IP Connection Between MATLAB 2017b and MATLAB 2024a

This guide explains how to establish a TCP/IP connection between MATLAB 2017b (Client) and MATLAB 2024a (Server) on the same computer or over a network. Before running this, initiliaze the bossdevice in Matlab 2024 version using b=bossdevice command. 

---

## **Setup on MATLAB 2017b (Client)**

1. **Open MATLAB 2017b** and create a TCP/IP client object.
    ```matlab
    client = tcpclient('127.0.0.1', 50000); % Use localhost or server IP
    ```

2. **Send a command to the server:**
    ```matlab
    write(client, 'b.sendPulse');
    ```

3. **(Optional) Read responses from the server:**
    ```matlab
    response = read(client);
    disp(char(response)); % Convert binary to text
    ```

---

## **Setup on MATLAB 2024a (Server)**

1. **Open MATLAB 2024a** and create a TCP/IP server object:
    ```matlab
    server = tcpserver(50000); % Port number must match the client
    ```

2. **Listen for incoming data and execute received commands:**
    ```matlab
    while true
        if server.BytesAvailable > 0
            data = read(server, server.BytesAvailable);
            command = char(data); % Convert received data to string
            eval(command); % Dynamically evaluate the command
        end
    end
    ```

3. **Send feedback to the client (if needed):**
    ```matlab
    write(server, 'Command executed successfully!');
    ```

---

## **Important Notes**

- **Firewall settings:** Ensure that the firewall allows traffic on the chosen port (50000 in this case).
- **Security considerations:** Use validation for the `eval` command to prevent unsafe execution:
    ```matlab
    if strcmp(command, 'b.sendPulse')
        eval(command);
    else
        disp('Invalid command received');
    end
    ```
- **For communication across machines:** Replace `127.0.0.1` with the actual IP address of the MATLAB 2024a machine.

---

## **Testing the Connection**

1. **Run the server script** in MATLAB 2024a.
2. **Run the client script** in MATLAB 2017b.
3. **Send the command** `b.sendPulse` from the client to confirm execution on the server.

---

### Example Code: MATLAB 2017b (Client)
```matlab
client = tcpclient('127.0.0.1', 50000);
write(client, 'b.sendPulse');
response = read(client);
disp(char(response));
