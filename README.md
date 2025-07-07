# factory-optimization
This is a scolar project made on Matlab, the main software we use in my school for coding. The goal is to optimize the production of factories according to the client's requests. These requests must be met within the deadlines.Deadlines are actually intervals, and delivering before or after the dates leads to penalties.
Each factory creates one type of product, and each clients wants different products within one delivery.
Moreover, the model accounts for several operational constraints and cost factors:
-maximum daily capacity
-stocking costs
-maximum flow capacity
-transportation costs

The result is a daily production, storage, and delivery schedule that satisfies all demands at minimum total cost.


The project includes multiple scenarios and progressive modeling questions, as described in the official assignment.
For full context and detailed specifications, please refer to the file `sujet.pdf`.

The file `Report.pdf` contains:
- Mathematical models for each scenario
- Answers to the theoretical questions
- Discussions and interpretations of the results


Exemple of input and output for the second scenario :

17 Days
7 Products
15 Clients
 
Input :
![screenshot_instance_1](https://github.com/user-attachments/assets/5e20e10a-ee77-43e0-a800-c2187c72a8a4)

Output :
Trucks to clients
(columns : days;
 rows : days)
![image](https://github.com/user-attachments/assets/ccf5a40b-fb37-470d-a0f7-7eafbf0bb0cd)

Trucks to factories 
(columns : days; rows : products)
![image](https://github.com/user-attachments/assets/421ccc24-c75b-4a9f-9552-63d5151e7a06)

Daily product made
(columns : days; rows : products)
![image](https://github.com/user-attachments/assets/0556239c-2bbe-4932-b1ff-2ede7436e380)

Product received by clients
(3D matrix 
columns : days; rows : products; depth : clients)
![image](https://github.com/user-attachments/assets/d3cd402f-443f-4142-8b10-50614357f24a)

Product stocked 
(columns : days; rows : products)
![image](https://github.com/user-attachments/assets/3caba8c8-0f4a-4202-9164-466826b90dbc)

Penalties
(columns : penalties; rows : days)
![image](https://github.com/user-attachments/assets/aae97735-5d14-40a9-97ae-38f22a205ef4)


