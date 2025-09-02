import streamlit as st;
import requests;

def bootstrap_frontend(){
    st.set_page_config(layout="wide");
    st.title("Codebase Genius");
    st.subheader("Generate a Markdown file from your input");

    # User input
    user_input = st.text_input("Enter your input (e.g., GitHub link or text):");

    # State to store generated markdown
    if "generated_md" not in st.session_state{
        st.session_state.generated_md = "";
    }

    # Generate button
    if st.button("Generate"){
        if not user_input.strip(){
            st.error("Please enter some input first.");
        }
        else{
            payload = {"message": user_input};
            response = requests.post(
                "http://localhost:8000/walker/clone_repo",
                json=payload
            );
            
        }
            if response.status_code == 200{
                response = response.json();
                print("response is",response);
                
                st.session_state.generated_md = "";
                for res in range(1,3){
                    st.session_state.generated_md += "## " + response["reports"][res]["name"] + "\n";
                    st.session_state.generated_md += response["reports"][res]["response"] + "\n\n";
                }
                st.markdown(st.session_state.generated_md);
                st.success("Markdown generated successfully!");
            }
            else{
                st.error(f"Error: {response.text}");
            }
    }
    # Download button if markdown exists
    if st.session_state.generated_md{
        st.download_button(
            label="Download Markdown",
            data=st.session_state.generated_md,
            file_name="output.md",
            mime="text/markdown"
        );
    }    
}
with entry{
    bootstrap_frontend();
}    
