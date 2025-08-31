import os ;
import shutil ;
import from git{Repo}
import from anytree{Node, RenderTree}
import from mtllm {Model}

#glob llm = Model(model_name = "gemini/gemini-2.0-flash");

glob IGNORED_FOLDERS:set[str] = {".git", "node_modules", "__pycache__"};

obj RepoMapper{
    has repo_url:str, clone_dir:str = "temp_repo", root_node:Node = None;

    def clone_repo{
        if os.path.exists(self.clone_dir){
            shutil.rmtree(self.clone_dir);
        }
        print(f"Cloning {self.repo_url} into {self.clone_dir}...");
        Repo.clone_from(self.repo_url, self.clone_dir);
    }

    def build_file_tree -> Node{
        self.root_node = Node(os.path.basename(self.clone_dir));
        nodes = {"": self.root_node};

        for (dirpath, dirnames, filenames) in os.walk(self.clone_dir){
            # Skip ignored folders
            dirnames[:] = [d for d in dirnames if d not in IGNORED_FOLDERS];

            relevant_path = os.path.relpath(dirpath, self.clone_dir);
            if relevant_path == "."{
                parent = self.root_node;
            } 
            else {
                parts = relevant_path.split(os.sep);
                parent_path = "";
                parent = self.root_node;
                for part in parts{
                    parent_path = f"{parent_path}/{part}" if parent_path else part;
                    if parent_path not in nodes{
                        nodes[parent_path] = Node(part, parent=parent);
                    }
                    parent = nodes[parent_path];
                }
            }
            for filename in filenames{
                Node(filename, parent=parent);
            }
        }
        return self.root_node;
    }

    def print_file_tree{
        if self.root_node is None{
            print("File tree not built yet. Call build_file_tree() first.");
            return;
        }
        for (pre, fill, node) in RenderTree(self.root_node){
            print("%s%s" % (pre, node.name));
        }
    }

    def read_readme{
        readme_path = os.path.join(self.clone_dir, "README.md");
        if os.path.exists(readme_path){
            with open(readme_path, "r", encoding="utf-8") as f{
                return f.read();
            }
        }
        return "No README file found.";
    }

}



with entry{
    repo_url = "https://github.com/jaseci-labs/littleX.git";
    mapper = RepoMapper(repo_url);
    mapper.clone_repo();
    mapper.build_file_tree();
    mapper.print_file_tree();
    readme_content = mapper.read_readme();
    summary = summarize(readme_content, 100);
    print("\nREADME.md Summary:\n", summary, "...");
}

