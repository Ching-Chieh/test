print("DFS: ")
def dfs(graph, node):
    visited = set()
    stack = []

    visited.add(node)
    stack.append(node) 

    while stack:
        s = stack.pop()
        print(s, end = ' ')

        for n in reversed(graph[s]):
            if n not in visited:
                visited.add(n)
                stack.append(n)
graph = {
  'A' : ['B','G'],
  'B' : ['C', 'D', 'E'],
  'C' : [],
  'D' : [],
  'E' : ['F'],
  'F' : [],
  'G' : ['H'],
  'H' : ['I'],
  'I' : [],
}

dfs(graph, 'A')

'''
stack
[A] [] [G, B]
[G] [G, E, D, C]
[G, E, D]
[G, E]
[G] [G, F]
[G]
[] [H]
[] [I]
[]
'''

print("\nBFS: ")
from collections import deque

def bfs(graph, node):
    visited = set()
    queue = deque()

    visited.add(node)
    queue.append(node)

    while queue:
        s = queue.popleft()
        print(s, end = ' ')

        for n in graph[s]:
            if n not in visited:
                visited.add(n)
                queue.append(n)
graph = {
  'A' : ['B','C'],
  'B' : ['D', 'E', 'F'],
  'C' : ['G'],
  'D' : [],
  'E' : [],
  'F' : ['H'],
  'G' : ['I'],
  'H' : [],
  'I' : []
}
bfs(graph, 'A')
'''
queue
[A]
[] [B, C]
[C] [C, D, E, F]
[D, E, F] [D, E, F, G]
[E, F, G]
[F, G]
[G] [G, H]
[H] [H, I]
[I]
[]
'''


