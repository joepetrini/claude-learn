<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    <!-- Screen View Header -->
    <div class="print:hidden">
      <nav class="bg-white dark:bg-gray-800 shadow-sm border-b dark:border-gray-700">
        <div class="container mx-auto px-4 py-4 flex justify-between items-center">
          <router-link to="/" class="text-blue-600 hover:text-blue-800 font-medium">
            ← Back to Modules
          </router-link>
          <button
            @click="printCheatSheet"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2z" />
            </svg>
            Print / Save as PDF
          </button>
        </div>
      </nav>
    </div>

    <!-- Printable Content -->
    <div class="container mx-auto px-4 py-8 max-w-4xl print:max-w-none print:px-0">
      <!-- Title -->
      <div class="text-center mb-8 print:mb-4">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white print:text-2xl">Claude Code Quick Reference</h1>
        <p class="text-gray-600 dark:text-gray-300 mt-2 print:text-sm">Essential commands and workflows for Python/Django developers</p>
      </div>

      <!-- Two Column Layout -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 print:grid-cols-2 print:gap-4">
        
        <!-- Essential Commands -->
        <section class="bg-white dark:bg-gray-800 rounded-lg shadow-md dark:shadow-gray-700/30 p-6 print:shadow-none print:border print:p-4">
          <h2 class="text-xl font-bold mb-4 text-gray-900 dark:text-white print:text-lg">Essential Commands</h2>
          
          <div class="space-y-3 print:space-y-2">
            <div>
              <code class="text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded print:bg-gray-50">claude</code>
              <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">Start interactive session</p>
            </div>
            
            <div>
              <code class="text-sm bg-gray-100 px-2 py-1 rounded print:bg-gray-50">claude "task description"</code>
              <p class="text-sm text-gray-600 mt-1">Execute specific task</p>
            </div>
            
            <div>
              <code class="text-sm bg-gray-100 px-2 py-1 rounded print:bg-gray-50">claude --think "complex task"</code>
              <p class="text-sm text-gray-600 mt-1">Extended thinking mode</p>
            </div>
            
            <div>
              <code class="text-sm bg-gray-100 px-2 py-1 rounded print:bg-gray-50">claude /review file.py</code>
              <p class="text-sm text-gray-600 mt-1">Code review with security & performance</p>
            </div>
          </div>
        </section>

        <!-- Slash Commands -->
        <section class="bg-white rounded-lg shadow-md p-6 print:shadow-none print:border print:p-4">
          <h2 class="text-xl font-bold mb-4 text-gray-900 print:text-lg">Slash Commands</h2>
          
          <div class="space-y-3 print:space-y-2">
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50">/init</code>
                <span class="text-gray-600 ml-2">Create CLAUDE.md</span>
              </div>
              <div>
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50">/clear</code>
                <span class="text-gray-600 ml-2">Clear context</span>
              </div>
              <div>
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50">/compact</code>
                <span class="text-gray-600 ml-2">Compress context</span>
              </div>
              <div>
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50">/cost</code>
                <span class="text-gray-600 ml-2">Check usage</span>
              </div>
              <div>
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50">/resume</code>
                <span class="text-gray-600 ml-2">Continue session</span>
              </div>
              <div>
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50">/doctor</code>
                <span class="text-gray-600 ml-2">Diagnose issues</span>
              </div>
            </div>
          </div>
        </section>

        <!-- Django Workflows -->
        <section class="bg-white rounded-lg shadow-md p-6 print:shadow-none print:border print:p-4">
          <h2 class="text-xl font-bold mb-4 text-gray-900 print:text-lg">Django Workflows</h2>
          
          <div class="space-y-3 print:space-y-2 text-sm">
            <div class="border-l-4 border-blue-500 pl-3">
              <p class="font-semibold">Create Feature</p>
              <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-1 print:bg-gray-50">
                claude "Create blog app with Post model, views, and tests"
              </code>
            </div>
            
            <div class="border-l-4 border-green-500 pl-3">
              <p class="font-semibold">API Development</p>
              <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-1 print:bg-gray-50">
                claude "Create DRF ViewSet for User model with pagination"
              </code>
            </div>
            
            <div class="border-l-4 border-purple-500 pl-3">
              <p class="font-semibold">Testing</p>
              <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-1 print:bg-gray-50">
                claude "Write tests for OrderService using pytest"
              </code>
            </div>
          </div>
        </section>

        <!-- Keyboard Shortcuts -->
        <section class="bg-white rounded-lg shadow-md p-6 print:shadow-none print:border print:p-4">
          <h2 class="text-xl font-bold mb-4 text-gray-900 print:text-lg">Keyboard Shortcuts</h2>
          
          <div class="space-y-2 text-sm">
            <div class="grid grid-cols-2 gap-2">
              <div class="flex justify-between">
                <span>Copy code</span>
                <kbd class="px-2 py-1 bg-gray-100 rounded text-xs print:bg-gray-50">Ctrl+C</kbd>
              </div>
              <div class="flex justify-between">
                <span>Paste image</span>
                <kbd class="px-2 py-1 bg-gray-100 rounded text-xs print:bg-gray-50">Ctrl+V</kbd>
              </div>
              <div class="flex justify-between">
                <span>Interrupt</span>
                <kbd class="px-2 py-1 bg-gray-100 rounded text-xs print:bg-gray-50">Ctrl+C</kbd>
              </div>
              <div class="flex justify-between">
                <span>Exit</span>
                <kbd class="px-2 py-1 bg-gray-100 rounded text-xs print:bg-gray-50">Ctrl+D</kbd>
              </div>
            </div>
            
            <div class="mt-3 pt-3 border-t">
              <p class="font-semibold mb-2">macOS Screenshot → Claude</p>
              <p class="text-xs text-gray-600">1. <kbd class="px-1 bg-gray-100 rounded print:bg-gray-50">Ctrl+Shift+Cmd+4</kbd> to capture</p>
              <p class="text-xs text-gray-600">2. <kbd class="px-1 bg-gray-100 rounded print:bg-gray-50">Ctrl+V</kbd> in terminal to paste</p>
            </div>
          </div>
        </section>

        <!-- Pro Tips -->
        <section class="bg-white rounded-lg shadow-md p-6 print:shadow-none print:border print:p-4 md:col-span-2 print:break-inside-avoid">
          <h2 class="text-xl font-bold mb-4 text-gray-900 print:text-lg">Pro Tips</h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <h3 class="font-semibold text-gray-800 mb-2">Performance</h3>
              <ul class="space-y-1 text-gray-600">
                <li>• Use <code class="bg-gray-100 px-1 rounded print:bg-gray-50">/compact</code> for long sessions</li>
                <li>• Be specific in requests to reduce tokens</li>
                <li>• Batch related changes together</li>
              </ul>
            </div>
            
            <div>
              <h3 class="font-semibold text-gray-800 mb-2">Best Practices</h3>
              <ul class="space-y-1 text-gray-600">
                <li>• Review changes before committing</li>
                <li>• Use Plan Mode for complex features</li>
                <li>• Keep CLAUDE.md updated with conventions</li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Common Patterns -->
        <section class="bg-white rounded-lg shadow-md p-6 print:shadow-none print:border print:p-4 md:col-span-2 print:break-inside-avoid">
          <h2 class="text-xl font-bold mb-4 text-gray-900 print:text-lg">Common Django Patterns</h2>
          
          <div class="space-y-3 text-sm">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <code class="bg-gray-100 p-2 rounded block print:bg-gray-50 text-xs">
                # Migrations<br>
                claude "Create migration to add indexes to User.email and User.username"
              </code>
              
              <code class="bg-gray-100 p-2 rounded block print:bg-gray-50 text-xs">
                # Optimization<br>
                claude "Optimize this view for N+1 queries using select_related"
              </code>
              
              <code class="bg-gray-100 p-2 rounded block print:bg-gray-50 text-xs">
                # Security Review<br>
                claude /review --scope=security views.py
              </code>
              
              <code class="bg-gray-100 p-2 rounded block print:bg-gray-50 text-xs">
                # Refactoring<br>
                claude "Refactor this view to use Django CBVs"
              </code>
            </div>
          </div>
        </section>
      </div>

      <!-- Footer -->
      <div class="mt-8 text-center text-sm text-gray-500 print:mt-4">
        <p>Claude Code Quick Reference • Generated from claude-learn</p>
        <p class="print:hidden">Press Ctrl+P (Cmd+P on Mac) to print or save as PDF</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const printCheatSheet = () => {
  window.print()
}
</script>

<style>
@media print {
  @page {
    size: A4;
    margin: 1cm;
  }
  
  body {
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
  }
  
  .print\:break-inside-avoid {
    break-inside: avoid;
  }
}
</style>