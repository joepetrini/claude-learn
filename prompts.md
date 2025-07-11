```
heres what this project is for, my team recently starting using "Claude
Code" and some people are adopting it better than others. I want to
create an e-learning app that uses the Claude Code documentation as source
material to craft a light and fun learning tool my team members can use
to ensure they are aware of all that claude code can do for them.
he documentation is here:
https://docs.anthropic.com/en/docs/claude-code/overview
create a docs folder with an overview of what we will build
this tool should have a few quick 'modules' that teaches something about
claude code with useful examples. We are primarily a python / django
codebase if that helps tailor the examples.
the content should cover:

- general overview of what Claude Code is and how to use it. How is it
  different than ChatGPT or AI coding tools like Github CoPilot or Cursor
- Common workflows and why to use them
- What can Claude do and cannot do?
- What are modes and mode switching? How to switch and why?
- How does history work and what slash cmds are related? /clear and
  /compact
- What is the CLAUDE.md file and where can they reside? What about
  CLAUDE.local.md? Can i have multiple in my project? Why?
- What are claude hooks and how are they configured? Provide useful
  eamples
- Can i use MCP tools? Where are they configed? Can my machine have a
  global list of MCP tools that all my projects share?
- Whare a memories and how and why would I use them? Do they have diff
  contexts? Why?
  Each module should have a quick multiple choice quiz where users answers
  are tracked for a score at the end.
  Based on the overview above is there anything I might be missing? Either
  in the functinoaliy of the app or in the content of the material my team
  members might need to learn about Claude Code?
```

Additional Content to Include:

- /review command for code reviews
- /pr_comments for viewing GitHub PR comments
- Extended thinking mode for complex problems
- Image analysis capabilities
  - how to send screenshots -> ctrl+shift+cmd+4 and then paste in iterm2 with ctrl+v not cmd+v
    use cases for this like fixing UI issues
  - can claude create diagrams? how?
- Custom slash commands creation
- Shared CLAUDE.md conventions
- Team leaderboard/gamification
- IDE integrations (VS Code)
- CI/CD pipeline integration
- GitHub Actions workflows
