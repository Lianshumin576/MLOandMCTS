function [root, terminal_node, arm] = mcts_plus(root, num_sta, num_arm, fixloc, Random)  



        arm = zeros(1, num_sta);
        current_node = root;
        terminal_node = root;
        temparm = [];

        if root.stopheight ~= 0
            for i = 1:root.stopheight
                current_node = current_node.child{root.recordnode(i)};%jump to D_h
            end
        end
       
        while ~current_node.is_terminal()
            
            if isempty(current_node.child) 
            current_node.expand(current_node, num_arm); %  expension
            end
            
            if current_node.travel_time ~= 0  
                current_node = current_node.select_best(current_node); 
                current_node.travel_time = current_node.travel_time+1;
            else  %MC simulation
                current_node = current_node.child{1+round(rand()*(num_sta-1))};
            end
        end  
        if current_node.is_terminal()
            terminal_node = current_node;
            for i = 1:terminal_node.tree_height
                temparm = [current_node.arm_index, temparm];
                current_node = current_node.parent;
            end
        end
        arm(fixloc) = Random;
        arm(arm==zeros(1, num_sta)) = temparm;


 end