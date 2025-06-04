classdef StateNode_BAI  < handle  
    properties  
        arm_index
        parent
        child
        reward
        node_height
        tree_height
        travel_time
        num_arm
        stopheight %eta
        recordnode %D
        delta
        epsilon
        betabar %paper:an varepsilon best arm identification algorithm for fixed confidence and beyond
        TBC
        NBC
    end  

    methods  
        function node = StateNode_BAI(arm_index, parent, node_height, num_sta, num_arm, epsilon, delta)  
            node.arm_index = arm_index;  
            node.parent = parent;  
            node.reward = 0;  
            node.node_height = node_height;
            node.tree_height = num_sta;
            node.travel_time = 0;
            node.num_arm = num_arm;
            node.stopheight = 0;
            node.recordnode = [];
            node.epsilon = epsilon;
            node.delta = delta;
            node.betabar = 1/2*ones(1,num_arm);
            node.TBC = zeros(1,num_arm);
            node.NBC = zeros(1,num_arm);
        end  
        

        function node = expand(~,node, num_arm)  
            child_nodes = cell(1, num_arm);  
            for i = 1:num_arm  
                child_nodes{i} = StateNode_BAI(i, node, node.node_height+1, node.tree_height, node.num_arm, node.epsilon, node.delta); % 假设状态i是合法的状态  
            end  
            node.child = child_nodes;
        end  
%% BAI         
        function node = select_best(~,node)  

            stop = 26;
            if ~isempty(find(cellfun(@(child) child.travel_time, node.child) == 0)) % has unexplored child nodes
            maxPositions = find(cellfun(@(child) child.travel_time, node.child) == 0);
            best_index = maxPositions(1+floor(rand()*(length(maxPositions)-1)));
            node = node.child{best_index}; 

            else
         
            [leaderValue, ~] = max(cellfun(@(child) child.reward/child.travel_time, node.child)); 
            leaderPositions = find(cellfun(@(child) child.reward/child.travel_time, node.child) == leaderValue);
            leader_index = leaderPositions(1+floor(rand()*(length(leaderPositions)-1)));
            leadernode = node.child{leader_index};


            temp_reward = leadernode.reward;
            leadernode.reward = 0;

            [minValue, ~] = min(cellfun(@(child) (leaderValue-(child.reward/child.travel_time)+child.epsilon)/sqrt(1/child.travel_time+1/leadernode.travel_time), node.child)); 
            maxPositions = find(cellfun(@(child) (leaderValue-(child.reward/child.travel_time)+child.epsilon)/sqrt(1/child.travel_time+1/leadernode.travel_time), node.child) == minValue);

            challenger_index = maxPositions(1+floor(rand()*(length(maxPositions)-1)));
            challengernode = node.child{challenger_index};
            leadernode.reward = temp_reward;
            leadernode.betabar(challenger_index) = (leadernode.betabar(challenger_index)*leadernode.TBC(challenger_index)+challengernode.travel_time/(leadernode.travel_time+challengernode.travel_time))/(leadernode.TBC(challenger_index)+1);
            leadernode.TBC(challenger_index) = leadernode.TBC(challenger_index)+1;
            


            if leadernode.NBC(challenger_index) <= (1-leadernode.betabar(challenger_index))*leadernode.TBC(challenger_index)
             node = challengernode; 
             leadernode.NBC(challenger_index) = leadernode.NBC(challenger_index)+1;
            else
             node = leadernode; 
            end

            if stop*minValue >= sqrt(2*(2*(log10((node.parent.num_arm-1)/node.delta)/2+log10(log10((node.parent.num_arm-1)/node.delta)/2))+4*log10(4+log10(node.parent.travel_time/2))))
                 % stop
                node = leadernode; 
                node.recordnode = leader_index;
                node.stopheight = inf;
            end
            
            
            
            end 
        end
          
        function backpropogate(~,node, reward)  

            root = node;
            while root.arm_index  
                root = root.parent;
            end
            while node.arm_index  
                if node.travel_time ~= 0
                 node.reward = node.reward+reward;
                end
                if (node.node_height == root.stopheight+1) && (node.stopheight == inf)
                    root.stopheight = root.stopheight+1;
                    root.recordnode = [root.recordnode,node.recordnode];
                end
              node = node.parent;
            end  
              node.travel_time =  node.travel_time+1;
              node.reward = node.reward+reward;
        end  


  
          
        function is_terminal = is_terminal(node)  
            is_terminal = isequal(node.node_height, node.tree_height); 
        end  
    end  
      
     
end