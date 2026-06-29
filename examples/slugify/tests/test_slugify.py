import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from textutils import slugify


# --- from change: add-slugify ---
def test_basic_words():
    assert slugify("Hello World") == "hello-world"

def test_collapse_punctuation_and_whitespace():
    assert slugify("  Foo --   Bar!! ") == "foo-bar"

def test_empty_input():
    assert slugify("") == ""


# --- from change: slugify-options ---
def test_underscore_is_separator():
    assert slugify("foo_bar baz") == "foo-bar-baz"

def test_custom_separator():
    assert slugify("Hello World", sep="_") == "hello_world"


if __name__ == "__main__":
    fns = [v for k, v in sorted(globals().items()) if k.startswith("test_")]
    for f in fns:
        f()
    print(f"all {len(fns)} tests passed")
