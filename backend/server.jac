include jaclens;
import sys;
import shutil;
import from mtllm.llm {Model}
import from mtllm.types {Text}
import from git{Repo}
import os;
import base64;
import requests;
import anyio;
import from tools {RepoMapper}

glob repo_mapper:RepoMapper = RepoMapper();
glob llm = Model(model_name='mistral/mistral-medium-latest', verbose=True);


node summerizer{
    def summarize(content: str, max_words: int) -> str by llm();

    can summarize_readme with infer entry {
        readme_path = os.path.join(visitor.clone_dir, "README.md");
        if os.path.exists(readme_path){
            repo_mapper.add_file1(readme_path);
        } else {
            report{"response": "No README file found."};
        }

        chunk_summery = [];
        results = repo_mapper.get_from_chroma(query="summarize the content",chunck_nos=10);
        for doc in results{
            summary = self.summarize(doc, max_words=100);
            chunk_summery.append(summary);
        }
        final_summary = self.summarize(", ".join(chunk_summery), max_words = 150);
        report{"response": final_summary};
    }    
}

# def list_tools() -> list[str] {
#     return [repo_mapper.load_repo_files];
# }

# def use_tool() -> str{
#     return repo_mapper.load_repo_files(repo_mapper.clone_dir);
# }

    

# def add_repo_file(clone_dir:str) -> str {
#     repo_mapper.add_file(clone_dir);
#     return f"Added files from {clone_dir}";
# }


node tree_generator{
    def generate_tree(message: str) -> str by llm(
        method="ReAct",
        tools=[add_repo_file]
    );

    can generate with clone_repo entry{
        clone_dir = visitor.clone_dir;
        response = self.generate_tree(message="give me summery of this repo",);
        report{"response": response};
    }
}

walker infer{
    has message:str;
    has clone_dir:str = "temp_repo";
    #has documents:list[dict];
    
    can init_route with `root entry {
        visit[-->](`?summerizer) else {
            tree_node = here ++> summerizer();
            visit tree_node;
        }
    }
}


node event{
    has clone_dir:str = "temp_repo";

    can chat with clone_repo entry{
        response1 = infer(message = visitor.message) spawn root;
        
        report {"response": response1};
    }
}

walker clone_repo{
    has message:str;
    has clone_dir:str = "temp_repo";

    obj _specs_ {
        static has auth: bool=False;
    }

    can clone with `root entry {
        if not os.path.exists(self.clone_dir){
            os.makedirs(self.clone_dir);
        }
        if os.path.exists(self.clone_dir){
            shutil.rmtree(self.clone_dir);
        }
        print(f"Cloning {self.message} into {self.clone_dir}...");
        Repo.clone_from(self.message, self.clone_dir);

        # repo_mapper.add_file(self.clone_dir);
        
        report{
            "status": "success",
            "message": f"Repository cloned to {self.clone_dir}"
        };
    }

    can init_event with `root entry {
        visit [-->](`?event)else {
            event_node = here ++> event(clone_dir=self.clone_dir);
            print("Event Node Created");
            visit event_node;
        }
    }    
 
}
# node CodeBase(Chat){
#     has chat_type:ChatType = ChatType.CODEBASE;


    
    

#     # can chat with infer entry{
#     #     read_content = self.repo_mapper.read_readme();
#     #     response = self.summarize(read_content, 100);
#     #     print("Summary of README:", response);

#     # }

# }



# walker infer {
#     has message:str;
#     has chat_history: list[dict];
#     has file_path: str = "";

#     can init_chat with `root entry {
#         chat_node = here ++> Chat(chat_type=ChatType.CODEBASE);
#         visit chat_node;
#     }

#     can route with Chat entry {
#         print("Routing message:", self.message, "to chat type:", here.chat_type);
#         visit here;
#     }
# }



    
    
# with entry{
#     clone_dir = "/home/heshan0926/Projects/Codebase_Genius/backend/temp_repo";
#     print(add_repo_file());
# }
