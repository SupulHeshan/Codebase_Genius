#!/usr/bin/env python3
"""
Extract module-level elements (classes, functions, globals) from Python files using tree-sitter.
"""

import os
import sys
from pathlib import Path
from typing import Optional, List

try:
    import tree_sitter_python as tspython
    from tree_sitter import Language, Parser, Node
except ImportError:
    print("Please install tree-sitter and tree-sitter-python:")
    print("pip install tree-sitter tree-sitter-python")
    sys.exit(1)


class ModuleElementExtractor:
    def __init__(self):
        # Create the language
        PY_LANGUAGE = Language(tspython.language())
        
        # Create parser with the language
        self.parser = Parser(PY_LANGUAGE)
    
    def extract_elements(self, source_code: str) -> List[str]:
        """Extract module-level elements from Python source code."""
        tree = self.parser.parse(bytes(source_code, "utf8"))
        root_node = tree.root_node
        elements = []
        
        def get_node_text(node: Node) -> str:
            """Get text content of a node."""
            if node.text is None:
                return ""
            return node.text.decode('utf-8')
        
        def get_class_bases(class_node: Node) -> str:
            """Extract base classes from a class definition."""
            bases = []
            argument_list = class_node.child_by_field_name("superclasses")
            if argument_list:
                for child in argument_list.children:
                    if child.type == "identifier":
                        bases.append(get_node_text(child))
                    elif child.type == "attribute":
                        bases.append(get_node_text(child))
                    elif child.type == "subscript":
                        bases.append(get_node_text(child))
            return f"({', '.join(bases)})" if bases else ""
        
        def visit_node(node: Node, indent: int = 0):
            """Recursively visit nodes and extract relevant elements."""
            indent_str = "    " * indent
            
            if node.type == "class_definition":
                name_node = node.child_by_field_name("name")
                if name_node:
                    name = get_node_text(name_node)
                    bases = get_class_bases(node)
                    elements.append(f"{indent_str}class {name}{bases}:")
                    
                    # Look for nested classes and methods
                    body = node.child_by_field_name("body")
                    if body:
                        for child in body.children:
                            if child.type in ["class_definition", "function_definition"]:
                                visit_node(child, indent + 1)
            
            elif node.type == "function_definition":
                name_node = node.child_by_field_name("name")
                if name_node:
                    name = get_node_text(name_node)
                    # Check if it's a method (inside a class) or module-level function
                    if indent == 0:
                        elements.append(f"{indent_str}def {name}():")
                    else:
                        elements.append(f"{indent_str}def {name}():")
            
            elif node.type == "assignment" and indent == 0:
                # Only capture module-level assignments
                left = node.child_by_field_name("left")
                if left and left.type == "identifier":
                    var_name = get_node_text(left)
                    elements.append(f"{indent_str}{var_name} = ...")
            
            elif node.type == "expression_statement" and indent == 0:
                # Handle other module-level statements
                if node.children:
                    child = node.children[0]
                    if child and child.type == "assignment":
                        visit_node(child, indent)
        
        # Visit all top-level nodes
        for child in root_node.children:
            if child.type in ["class_definition", "function_definition", "assignment", "expression_statement"]:
                visit_node(child)
        
        return elements
    
    def extract_from_file(self, file_path: str, output_file: Optional[str] = None):
        """Extract elements from a Python file and save to output file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                source_code = f.read()
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")
            return
        
        elements = self.extract_elements(source_code)
        
        if not output_file:
            output_file = f"{Path(file_path).stem}_elements.txt"
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(f"# Module elements extracted from: {file_path}\n\n")
                for element in elements:
                    f.write(element + "\n")
            
            print(f"✅ Module elements extracted to: {output_file}")
            print(f"📊 Found {len(elements)} elements")
            
            # Print first few elements as preview
            if elements:
                print("\n📋 Preview:")
                for i, element in enumerate(elements[:10]):
                    print(f"  {element}")
                if len(elements) > 10:
                    print(f"  ... and {len(elements) - 10} more")
                    
        except Exception as e:
            print(f"Error writing to file {output_file}: {e}")


def main():
    extractor = ModuleElementExtractor()
    
    # Default to unitree.py if no arguments provided
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = "/home/heshan0926/test.py"
    

    # Check if file exists
    if not os.path.exists(input_file):
        print(f"❌ File not found: {input_file}")
        print("Usage: python extract_module_elements_improved.py [python_file]")
        return
    
    output_file = f"{Path(input_file).stem}_elements.txt"
    
    print(f"🔍 Extracting elements from: {input_file}")
    extractor.extract_from_file(input_file, output_file)

    


if __name__ == "__main__":
    main()
    


        

