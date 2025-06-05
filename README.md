WiFi networks have achieved remarkable success in enabling seamless communication and data exchange worldwide. The IEEE 802.11be standard, known as WiFi 7, introduces Multi-Link Operation (MLO), a groundbreaking feature that enables devices to establish multiple simultaneous connections across different bands and channels. While MLO promises substantial improvements in network throughput and latency reduction, it presents significant challenges in channel allocation, particularly in dense network environments.
Current research has predominantly focused on performance analysis and throughput optimization within static WiFi 7 network configurations. In contrast, this paper addresses the dynamic channel allocation problem in dense WiFi 7 networks with MLO capabilities. We formulate this challenge as a combinatorial optimization problem, leveraging a novel network performance analysis mechanism. Given the inherent lack of prior network information, we model the problem within a Multi-Armed Bandit (MAB) framework to enable online learning of optimal channel allocations. Our proposed Best-Arm Identification-enabled Monte Carlo Tree Search (BAI-MCTS) algorithm includes rigorous theoretical analysis, providing upper bounds for both sample complexity and error probability. To further reduce sample complexity and enhance generalizability across diverse network scenarios, we put forth LLM-BAI-MCTS, an intelligent algorithm for the dynamic channel allocation problem by integrating the Large Language Model (LLM) into the BAI-MCTS algorithm. 
Numerical results demonstrate that the BAI-MCTS algorithm achieves a convergence rate approximately $50.44$% faster than the state-of-the-art algorithms when reaching $98$% of the optimal value. Notably, the convergence rate of the LLM-BAI-MCTS algorithm increases by over $63.32$% in dense networks.


## Key Features

1. **BAI-MCTS Algorithm Implementation**
   - Execute `BAI_MCTS_main.m` to run the core BAI-MCTS algorithm
   - The throughput calculation uses theoretical model from **Section V.D** of the paper
   - The throughput calculation can be replaced with other discrete event emulators to simulate real situations.

2. **LLM Integration Module**
   - Use `LLM_prompt.py` to interface with LLMs for channel allocation tasks
   - Pre-configured examples and network topologies 
   - The examples and new network information provided can be replaced

3. **Hybrid LLM-BAI-MCTS Workflow**
   - After obtaining LLM strategies:
     ```matlab
     % Modify BAI_MCTS_main.m parameters
     fixloc = [llm_strategy.STA_indexs];  % LLM-suggested STA indexs
     fixconf = [llm_strategy.channel_config]; % LLM-recommended channel assignments
     ```


## License

WirelessAgent<sup>2</sup> is MIT-licensed. The license applies to the pre-trained models and datasets as well.

## Citation

If you find the repository is helpful to your project, please cite as follows:

```bibtex
@article{lian2025intelligent,
  title={Intelligent Channel Allocation for IEEE 802.11be Multi-Link Operation: When MAB Meets LLM},
  author={Lian, shumin and Tong, Jingwen and Zhang, Jun and Fu, Liqun},
  journal={JSAC},
  year={2025}
}
```



