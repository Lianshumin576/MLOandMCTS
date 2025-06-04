import random
import sys
import scipy.io

# LangChain related
from langchain_openai import ChatOpenAI
# promote
max_example = 1 
allocation_data = scipy.io.loadmat('Data\\arm.mat')  
variable_name = 'arm'  
if variable_name in allocation_data:
    allocation = allocation_data[variable_name] 
else:
    print(f"Variable '{variable_name}' not found in .mat file.")
allocation = allocation[: max_example] 
stas_num = allocation.shape[1] 
##===========================input=======================================
###=============================location===================================

def load_and_process_locations(mat_file_path, variable_names, stas_num, i): 
    """
    Load data from a .mat file and process location information.

    Args:
        mat_file_path (str): Path to the .mat file.
        variable_names (list): List of variable names to load (e.g., ['xx1', 'yy1', 'xx2', 'yy2', 'xx3', 'yy3']).
        stas_num (int): Total number of stations.

    Returns:
        dict: A dictionary containing processed location information with keys 'location1_sta', 'location2_sta', 'location3_sta'.
    """
    # Load the .mat file
    location_data = scipy.io.loadmat(mat_file_path)

    # Get variable data
    variables = {}
    for var_name in variable_names:
        if var_name in location_data:
            variables[var_name] = location_data[var_name]
        else:
            print(f"Variable '{var_name}' not found in .mat file.")
            variables[var_name] = None

    # Process location information
    locations = {}
    for loc_idx in range(1, 4):  # Process location1, location2, location3
        location_key = f'location{loc_idx}_sta'
        locations[location_key] = ""
        var_prefix_x  = variable_names[0][:-1]  # Process variables with 'xx' and 'yy' prefixes
        var_prefix_y  = variable_names[1][:-1]
        var_x_name = f'{var_prefix_x}{loc_idx}'
        var_y_name = f'{var_prefix_y}{loc_idx}'
        x_data = variables[var_x_name][i]  # Take the first element (assuming it's an array)
        y_data = variables[var_y_name][i]
        for j in range(int(stas_num / 3)):
            if j < len(x_data):  # Ensure index is within bounds
                rounded_x_value = round(x_data[j], 2)
                rounded_y_value = round(y_data[j], 2)
                locations[location_key] += f"({rounded_x_value}, {rounded_y_value})"  # Example: assume xx and yy values are the same
            else:
                break  # Exit early if data is insufficient

        # Add curly braces
        locations[location_key] = "{" + locations[location_key] + "}"

    return locations


mat_file_path = 'Data\\example_location.mat'  
variable_names = ['xx1', 'yy1', 'xx2', 'yy2', 'xx3', 'yy3']
location1_ap = "(5, 7)" 
location2_ap = "(2.6, 3)"
location3_ap = "(7.6, 3)"


###===============================conflict==========================================
def filter_matrix(matrix):  

    filtered_matrix = []  
      
    for row in matrix:  
        STA1, STA2 = row  
        if STA1 < STA2:  
            filtered_matrix.append(row)  
    return filtered_matrix 
def matrix_to_STA_pairs(matrix): 
    if not matrix:
        return "There are no non-conflicting STA pairs"
    else: 
        STA_pairs = []  
        for row in matrix:  
            STA1, STA2 = row  
            pair_str = f"STA{STA1} and STA{STA2}"  
            STA_pairs.append(pair_str)  
        
        if(len(STA_pairs)>1): 
            output_str = ", ".join(STA_pairs[:-1]) + ", " + STA_pairs[-1]
        else:
            output_str = ", ".join(STA_pairs[:-1]) + STA_pairs[-1]
        return output_str + f" do not conflict with each other"  
def find_zeros(matrix):  
    zeros_positions = []  
      
    for i, row in enumerate(matrix):  
        for j, value in enumerate(row):  
            if value == 0:  
                zeros_positions.append((i, j))  
    return zeros_positions 


def load_and_process_conflict(mat_file_path, variable_names, i):
    """
    Load data from a .mat file and process location information.

    Args:
        mat_file_path (str): Path to the .mat file.
        variable_names (list): List of variable names to load (e.g., ['CS1', 'CS2', 'CS3']).
        i (int): i th CS.

    Returns:
        dict: A dictionary containing processed location information with keys 'CS1', 'CS2', 'CS3','BSS1', 'BSS2', 'BSS3'.
    """
    # Load the .mat file
    location_data = scipy.io.loadmat(mat_file_path)

    # Get variable data
    variables = {}
    for var_name in variable_names:
        if var_name in location_data:
            variables[var_name] = location_data[var_name]
        else:
            print(f"Variable '{var_name}' not found in .mat file.")
            variables[var_name] = None

    # Process location information
    conflict = {}
    for loc_idx in range(1, 4):  # Process channel1, channel2, channel3
        CS_key = f'CS{loc_idx}'
        Non_confkic_key = f'BSS{loc_idx}'
        conflict[CS_key] = ""
        conflict[Non_confkic_key] = []
        var_prefix_name  = f'CS{loc_idx}'
        CS_data = variables[var_prefix_name][i]  # Take the first element 
        zero_positions = find_zeros(CS_data)
        matrix_plus_one = [[x+1 for x in row] for row in zero_positions] 
        filtered_result = filter_matrix(matrix_plus_one) 
        conflict[CS_key] = matrix_to_STA_pairs(filtered_result)
        for row in filtered_result:
            for element in row:
                conflict[Non_confkic_key].append(element)
        
        conflict[Non_confkic_key] = list(set(conflict[Non_confkic_key]))

    return conflict


input_list = []
for i in range(max_example):
    result = load_and_process_locations(mat_file_path, variable_names, stas_num, i)
    conflict = load_and_process_conflict("Data\\example_CS.mat", ['CS1', 'CS2', 'CS3'], i)
    input_value = f"""You are an expert in WiFi network management. You need to maximize the network throughput by allocating available channel resources to different STAtions  (STAs). The IEEE 802.11be protocol has been adopted in the network, which supports Multi-Link Operation (MLO) with Simultaneous Transmit and Receive (STR) mode. Also, you need to think step-by-step to perform channel allocation based on the input network information. It is allowed for the same STA to be allocated to one channel in each frequency band at most. For example, when there are three Basic Service Sets (BSSs) in the network, each BSS has one Access Point (AP) and {int(stas_num / 3)} STAs. The location of the AP in the first BSS is {location1_ap}, and the STA locations are {result['location1_sta']}; the location of the AP in the second BSS is {location2_ap}, and the STA locations are {result['location2_sta']}; the location of the AP in the third BSS is {location3_ap}, and the STA locations are {result['location3_sta']}. These STAs are described as STA 1 to STA {int(stas_num)}, respectively. There are three channels in the wireless network resources, located at 2.4, 5, and 6 GHz, described as Channels 1, 2, and 3, respectively. {conflict['CS1']} in Channel 1. {conflict['CS2']} in Channel 2. {conflict['CS3']} in Channel 3."""
    input_list.append({"input": input_value})






##======================================cot and output========================================


channel1_map = [4, 5, 6, 7]
channel2_map = [2, 3, 6, 7]
channel3_map = [1, 3, 5, 7]

def process_allocation(allocation, channel_map): 
    result = []
    for i, num in enumerate(allocation):
        if num in channel_map:
            result.append(str(i+1))
    
    if len(result) > 1:
        last = result.pop()
        result[-1] = result[-1] + " and " + last
        return "STAs "+ ", ".join(result)
    elif len(result) == 1:
        return "STA "+result[0]
    else:
        return "None"
def find_allocation(allocation, channel_map): 
    allocation_BSS = []
    for i, num in enumerate(allocation):
        if num in channel_map:
            allocation_BSS.append(i+1)
    return allocation_BSS
def find_lowconflict_overlap(allocation_BSS, conflict_BSS): 

    if not conflict_BSS:
        if not allocation_BSS:
            return ". Here, STAs are distributed after further analysis in"
        else:
            return f", to avoid conflict, only one STA is selected from STAs. Here, STA {random.choice(allocation_BSS)} is selected in"


    set1 = set(allocation_BSS)
    set2 = set(conflict_BSS)
    
    result = set1.intersection(set2)
    
    result = list(map(str, result))
    if len(result) > 1:
        last = result.pop()
        result[-1] = result[-1] + " and " + last
        result = ". Here, STA "+", ".join(result)+" are selected in"
        return result
    elif len(result) == 1:
        return ". Here, STA "+result[0]+" is selected in"
    else:
        return ". Here, STAs are distributed after further analysis in"

cot_list = []
output_list = []
for i in range(len(allocation)):
    allocation_1 = process_allocation(allocation[i], channel1_map)  
    allocation_2 = process_allocation(allocation[i], channel2_map)
    allocation_3 = process_allocation(allocation[i], channel3_map)
    allocation_BSS1 = find_allocation(allocation[i], channel1_map)  
    allocation_BSS2 = find_allocation(allocation[i], channel2_map)
    allocation_BSS3 = find_allocation(allocation[i], channel3_map)
    conflict = load_and_process_conflict("Data\\example_CS.mat", ['CS1', 'CS2', 'CS3'], i)
    channel1_sta = conflict['CS1']+find_lowconflict_overlap(allocation_BSS1, conflict['BSS1'])
    channel2_sta = conflict['CS2']+find_lowconflict_overlap(allocation_BSS2, conflict['BSS2'])
    channel3_sta = conflict['CS3']+find_lowconflict_overlap(allocation_BSS3, conflict['BSS3'])
    cot_value = f"""Below is the channel allocation steps:    
    1) Perceive the network information: There are 3 channels in the network (2.4, 5, 6GHz, described as channels 1, 2, and 3, respectively), and {stas_num} STAs (STA 1 to STA {stas_num}) distributed across three BSSs. I need to pre-allocate them to each channel in order to configure them.
    2) Channel pre-allocation: According to the MLO-STR protocol, multiple links for the same STA are independent of each other, I need to balance the conflict relationship between different STAs. My goal is to maximize the network throughput by allocating available resources to the STA, while considering the MLO-STR protocol. It is allowed for the same STA to be allocated to one channel in each frequency band at most to increase throughput.
    3) Analyze the conflict relationships: According to the IEEE 802.11 standard, the CSMA protocol has been adopted to coordinate the transmissions among the STAs operated into the same channel. If two STAs transmit at the same time, there will be a conflict.
    4) Prioritize the allocation of low-conflict STAs: Channel 1: {channel1_sta} Channel 1. Channel 2: {channel2_sta} Channel 2. Channel 3: {channel3_sta} Channel 3.
    5) Allocate resources to all STAs: To utilize the advantages of MLO, we should further allocate channels for some STAs in order to maximize the throughput. Consider appropriately introducing STAs with minimal conflict with already allocated STAs or STAs with a large Euclidean distance. The final STAs assignment solution is: Channel 1: {allocation_1}; Channel 2: {allocation_2}; Channel 3: {allocation_3}."""
    output_value = f"""The final STAs assignment solution is:
- Channel 1: {allocation_1}
- Channel 2: {allocation_2}
- Channel 3: {allocation_3}"""
    cot_list.append({"cot": cot_value})
    output_list.append({"output": output_value})






mat_file_path = 'Data\\location.mat'  
variable_names = ['x1', 'y1', 'x2', 'y2', 'x3', 'y3']
result = load_and_process_locations(mat_file_path, variable_names, stas_num, 0)
conflict = load_and_process_conflict("Data\\CS.mat", ['CS1', 'CS2', 'CS3'], 0)
stas_num = 24
cot_values = [cot["cot"] for cot in cot_list]
input_values = [input_item["input"] for input_item in input_list]
output_values = [output_item["output"] for output_item in output_list]
new_network = f"""Please follow the above steps. You need to carefully consider the allocation of resources to the STAs in the following network, and give the final configuration after all the STAs have been assigned. 
There are three Basic Service Sets (BSSs) in the network, each BSS has one Access Point (AP) and {int(stas_num / 3)} STAs. The location of the AP in the first BSS is {location1_ap}, and the STA locations are {result['location1_sta']}; the location of the AP in the second BSS is {location2_ap}, and the STA locations are {result['location2_sta']}; the location of the AP in the third BSS is {location3_ap}, and the STA locations are {result['location3_sta']}. These STAs are described as STA 1 to STA {int(stas_num)}, respectively. There are three channels in the wireless network resources, located at 2.4, 5, and 6 GHz, described as Channels 1, 2, and 3, respectively. {conflict['CS1']} in Channel 1. {conflict['CS2']} in Channel 2. {conflict['CS3']} in Channel 3."""
combined_list = []
combined_list.extend([
    f"{input_item}\n{cot}\n{output_item}\n{new_network}"
    for input_item, cot, output_item in zip(
        input_values, 
        cot_values, 
        output_values
    )
])




#==========================Set up LLM====================================
llm = ChatOpenAI(
    api_key="your api_key",
    base_url="corresponding URL",
    model="corresponding LLM",
    temperature=0
)

#=======================Call for LLM============================
response = llm.invoke(combined_list[0])
evaluation = response.content
print(evaluation)