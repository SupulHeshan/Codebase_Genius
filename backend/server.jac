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
glob llm = Model(model_name='mistral/mistral-large-latest', verbose=True);


def list_tools() -> list[str] {
    return ["get_from_chroma"];
}

def use_tool() -> str{
    return repo_mapper.get_from_chroma(query="all the content",chunck_nos=1);
}


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
        report{"name":"Summary of the README.md file","response": final_summary};
    }    
}

node tree_generator{
    def generate_tree(message: str) -> str by llm(
        method="ReAct",
        tools=[list_tools, use_tool]
    );

    can generate with infer entry{
        clone_dir = visitor.clone_dir;
        repo_mapper.add_file(clone_dir);
        response = self.generate_tree(message="generate a tree using this",);
        report{"name":"Structure of Files in Repository","response": response};
    }
}

walker infer{
    # has message:str;
    has clone_dir:str = "temp_repo";
    #has documents:list[dict];
    
    can init_route with `root entry {
        visit[-->](`?tree_generator) else {
            tree_node = here ++> tree_generator();
            visit tree_node;
        }
        visit[-->](`?summerizer) else {
            tree_node = here ++> summerizer();
            visit tree_node;
        }
    }
}


node event{
    has clone_dir:str = "temp_repo";

    can chat with clone_repo entry{
        response_list = [];
        response = infer(message = visitor.message) spawn root;
        response_list.append(response);
        
        report {"response": response_list};  #have the chack this when remove it still works
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

