import sys;
import shutil;
import from byllm.llm {Model}
import from byllm.types {Text}
import from git{Repo}
import os;
import base64;
import requests;
import anyio;
import from tools {RepoMapper}
import re;
import from pathlib {Path}
import from tool_tree_sitter {ModuleElementExtractor}

glob repo_mapper:RepoMapper = RepoMapper();
glob tool_t_sitter:ModuleElementExtractor = ModuleElementExtractor();
glob llm = Model(model_name='mistral/mistral-large-latest', verbose=True);


def list_tools() -> list[str] {
    return ["get_from_chroma"];
}

def use_tool() -> str{
    return repo_mapper.get_from_chroma(query="all the content",chunck_nos=1);
}


node summerizer{
    def summarize(content: str, max_words: int) -> str by llm();

    can summarize_readme with clone_repo entry {
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

    can generate with clone_repo entry{
        clone_dir = visitor.clone_dir;
        repo_mapper.add_file(clone_dir);
        response = self.generate_tree(message="generate a tree using this",);
        report{"name":"Structure of Files in Repository","response": response};
    }
}

node repo_analyzer {
    def get_priority(prompt: str) -> str by llm();

    def get_doc(content:str) -> str by llm();

    can analyze_repo with clone_repo entry {
        with open("all_files.txt", "r") as f {
            priority = f.read();
        }
        prompt = """hey I am documenting this repo. 
        So can you tell me what are the file you need to look into and 
        recursively I need to check. It should be in high priority. 
        Can you give me it as a list. only High priority""";
        prompt += priority;
        priority_list = self.get_priority(prompt);
        # report{"name":"name", "response": priority_list};
        paths = re.findall(r'`([^`]*)`', priority_list);
        
        for path in paths{
            if os.path.isfile(path){
                content = "";
                tool_t_sitter.extract_from_file(path);
                with open(path, "r", encoding="utf-8") as f{
                    content = f.read();
                }
            
                content+= " Give the high quality documentation of this content:";
                documentation = self.get_doc(content);
                print(path);
                print(documentation);
                report{"name":path, "response":documentation};
            }else{
                print(f"⚠️ Skipping directory: {path}");
            }
            
        }    
    
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
    }

    can init_event with `root entry {
        visit[-->](`?tree_generator) else {
            tree_node = here ++> tree_generator();
            visit tree_node;
        }
        visit[-->](`?summerizer) else {
            tree_node = here ++> summerizer();
            visit tree_node;
        }
        visit[-->](`?repo_analyzer) else {
            tree_node = here ++> repo_analyzer();
            visit tree_node;
        }
    }    
 
}

