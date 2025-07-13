# Content Style Guide

**Version**: 1.0  
**Created**: January 13, 2025  
**Purpose**: Standardize content creation for the Claude Learn platform

## 1. Module Structure Standards

### Required Module Properties
```json
{
  "title": "Clear, actionable title (max 60 characters)",
  "description": "One-sentence description of learning outcomes",
  "slug": "kebab-case-module-identifier",
  "estimatedDuration": "X minutes (realistic estimates)",
  "difficultyLevel": "beginner|intermediate|advanced",
  "sortOrder": 1, // Sequential numbering, not 0
  "prerequisites": ["module-slug-1", "module-slug-2"], // Actual dependencies
  "learningObjectives": [
    "After completing this module, you will be able to...",
    "Clear, measurable learning outcomes"
  ],
  "sections": [
    {
      "title": "Section Title",
      "content": "HTML content following content standards"
    }
  ]
}
```

### Content Organization
- **Maximum 3-4 sections per module** for digestibility
- **15-30 minutes per module** - optimal learning session length
- **Logical progression** - each section builds on the previous
- **Clear section titles** that indicate what will be learned

## 2. Writing Standards

### Tone and Voice
- **Conversational but professional** - Write like you're teaching a colleague
- **Framework-agnostic** - Avoid bias toward specific technologies unless explicitly stated
- **Action-oriented** - Focus on what learners will do, not just what they'll know
- **Encouraging** - Assume learners can succeed with proper guidance

### Content Structure
```html
<h2>Section Title</h2>
<p>Brief introduction explaining what this section covers</p>

<h3>Key Concept</h3>
<p>Explanation with practical context</p>

<h4>Example:</h4>
<pre><code class="language-bash">
# Properly formatted code example
command --flag "example"
</code></pre>

<p>Explanation of the example and when to use it</p>
```

### Code Examples
- **Multi-platform support** - Include Windows/Linux/macOS alternatives when needed
- **Working examples** - All code must be tested and functional
- **Context provided** - Explain what each example accomplishes
- **Consistent formatting** - Use proper syntax highlighting

#### Code Block Standards
```html
<!-- Bash/Terminal commands -->
<pre><code class="language-bash">
claude "task description"
</code></pre>

<!-- Configuration files -->
<pre><code class="language-json">
{
  "key": "value"
}
</code></pre>

<!-- Multi-line examples with comments -->
<pre><code class="language-bash">
# Create a new feature
claude "implement user authentication"

# Review the changes
claude /review auth.py
</code></pre>
```

## 3. Quiz Standards

### Question Requirements
- **5 questions per module** (consistent across all modules)
- **70% pass threshold** (3.5/5 correct answers)
- **Practical application focus** - Test understanding, not memorization
- **Clear, unambiguous wording** - No trick questions
- **Realistic scenarios** - Questions should reflect actual usage

### Quiz Structure
```json
{
  "questions": [
    {
      "question": "Clear, specific question about practical application",
      "options": [
        "Incorrect but plausible option",
        "Correct answer that demonstrates understanding",
        "Another incorrect but reasonable option",
        "Clearly wrong option for elimination"
      ],
      "correct": 1, // Zero-indexed array position
      "explanation": "Explanation that teaches beyond just the answer"
    }
  ]
}
```

### Question Types to Use
- **Scenario-based**: "When would you use...?"
- **Command syntax**: "Which command accomplishes...?"
- **Best practices**: "What's the recommended approach for...?"
- **Troubleshooting**: "If you encounter X, you should...?"

### Avoid These Question Types
- Pure memorization ("What year was...?")
- Obscure edge cases
- Ambiguous wording
- Multiple correct answers without clear best choice

## 4. Resource Standards

### Resource Categories
1. **Cheat Sheets** - Quick reference for commands and workflows
2. **Links** - External documentation and tutorials
3. **Glossaries** - Definitions and explanations
4. **Templates** - Reusable code patterns and configurations

### Resource Properties
```json
{
  "id": "unique-resource-identifier",
  "title": "Clear, descriptive title",
  "description": "One sentence explaining the resource's value",
  "type": "cheat_sheet|links|glossary|template",
  "icon": "📋", // Relevant emoji
  "tags": ["relevant", "searchable", "keywords"],
  "isFeatured": false, // Only for exceptional resources
  "lastUpdated": "2025-01-13",
  "content": "Structured content following type-specific standards"
}
```

### Link Validation Requirements
- **All external links must be tested** before publication
- **Use official documentation** when available
- **Provide fallback options** for external resources
- **No placeholder or example.com links** in production

## 5. Accessibility Standards

### HTML Structure
- **Proper heading hierarchy** (h1 → h2 → h3, no skipping levels)
- **Semantic markup** - Use appropriate HTML elements
- **Alt text for images** - Descriptive, not decorative
- **Clear link text** - Avoid "click here" or "read more"

### Content Accessibility
- **Plain language** - Avoid unnecessary jargon
- **Consistent terminology** - Use the same terms throughout
- **Visual hierarchy** - Use headings, lists, and formatting effectively
- **Screen reader friendly** - Structure content logically

## 6. Technical Standards

### File Organization
```
course-slug/
├── course.json           // Course metadata
├── modules.json         // Module listing
├── module_1/
│   ├── content.json     // Module content
│   └── quiz.json        // Module quiz
├── module_2/
│   ├── content.json
│   └── quiz.json
└── resources/
    ├── cheat-sheet.json
    ├── links.json
    └── glossary.json
```

### Version Control
- **Atomic commits** - One logical change per commit
- **Descriptive commit messages** - "Update Module 5 quiz questions"
- **Content review required** - All changes reviewed before merge
- **Backup before major changes** - Preserve working versions

## 7. Quality Checklist

### Before Publishing Any Module
- [ ] Learning objectives clearly stated
- [ ] Content follows framework-agnostic approach
- [ ] All code examples tested and working
- [ ] Platform-specific instructions included where needed
- [ ] HTML structure follows accessibility standards
- [ ] Estimated duration is realistic
- [ ] Prerequisites accurately reflect dependencies
- [ ] Quiz has exactly 5 questions
- [ ] All quiz answers verified correct
- [ ] Explanations provide educational value

### Before Publishing Any Resource
- [ ] All external links tested and working
- [ ] Content provides clear, actionable value
- [ ] Formatting is consistent with style guide
- [ ] Tags are relevant and searchable
- [ ] Description accurately represents content
- [ ] Last updated date is current

### Course-Level Review
- [ ] Modules flow logically from basic to advanced
- [ ] No gaps in essential knowledge
- [ ] Consistent terminology throughout
- [ ] Appropriate total duration (3-6 hours ideal)
- [ ] Clear prerequisites between modules
- [ ] Resources complement module content

## 8. Content Types and Templates

### Module Template
```json
{
  "title": "Action-Oriented Module Title",
  "description": "Clear one-sentence learning outcome",
  "slug": "kebab-case-identifier",
  "estimatedDuration": "20 minutes",
  "difficultyLevel": "beginner",
  "sortOrder": 1,
  "prerequisites": [],
  "learningObjectives": [
    "Objective 1",
    "Objective 2"
  ],
  "sections": [
    {
      "title": "Introduction",
      "content": "<h2>What You'll Learn</h2><p>Brief overview...</p>"
    },
    {
      "title": "Core Concepts",
      "content": "<h2>Key Concepts</h2><p>Main content...</p>"
    },
    {
      "title": "Practical Application",
      "content": "<h2>Putting It Into Practice</h2><p>Examples...</p>"
    }
  ]
}
```

### Quiz Template
```json
{
  "questions": [
    {
      "question": "Scenario-based question about practical application?",
      "options": [
        "Plausible incorrect option",
        "Correct answer demonstrating understanding",
        "Another reasonable incorrect option",
        "Obviously wrong option"
      ],
      "correct": 1,
      "explanation": "Educational explanation that goes beyond just identifying the answer"
    }
  ]
}
```

This style guide ensures consistent, high-quality content that serves learners effectively across all courses and modules in the Claude Learn platform.