from crewai_tools import SerperDevTool

def get_search_tool():
    """
    Returns an instance of the SerperDevTool for web searching.
    Requires SERPER_API_KEY to be set in environment variables.
    """
    search_tool = SerperDevTool()
    return search_tool
