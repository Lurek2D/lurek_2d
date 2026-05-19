--@api-stub: LTreeView.addNode
--@api-stub: LTreeView.clearNodes
--@api-stub: LTreeView.collapseAll
-- LTreeView population and collapse.
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.collapseNode
--@api-stub: LTreeView.expandAll
--@api-stub: LTreeView.expandNode
-- LTreeView expand and collapse.
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1)
    tv:addNode("Dog", n2)
    tv:expandAll()
    tv:collapseNode(n1)
    tv:expandNode(n1)
    local cnt = tv:getNodeCount()
    print("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api-stub: LTreeView.getChildNodes
--@api-stub: LTreeView.getNodeCount
--@api-stub: LTreeView.getNodeDepth
-- LTreeView hierarchy queries.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r)
    tv:addNode("Child2", r)
    local children = tv:getChildNodes(r)
    local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    print("children:", children, "count:", cnt, "depth:", depth)
end

--@api-stub: LTreeView.getNodeText
--@api-stub: LTreeView.getParentNode
--@api-stub: LTreeView.getSelectedNode
-- LTreeView text and parent.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.isExpanded
--@api-stub: LTreeView.isNodeExpanded
--@api-stub: LTreeView.removeNode
-- LTreeView expansion and removal.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    tv:expandNode(r)
    local exp = tv:isExpanded(r)
    local ne = tv:isNodeExpanded(r)
    tv:removeNode(c)
    local cnt = tv:getNodeCount()
    print("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api-stub: LTreeView.setNodeIcon
--@api-stub: LTreeView.setNodeText
--@api-stub: LTreeView.setSelectedNode
-- LTreeView setters.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text")
    local txt = tv:getNodeText(r)
    tv:setSelectedNode(r)
    local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    print("setText:", txt, "selected:", sel)
end

--@api-stub: LTreeView.toggleNode
-- LTreeView toggleNode.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    tv:addNode("Child", r)
    tv:expandNode(r)
    local was = tv:isExpanded(r)
    tv:toggleNode(r)
    local now = tv:isExpanded(r)
    tv:toggleNode(r)
    local back = tv:isExpanded(r)
    print("expanded:", was, "after toggle:", now, "after toggle back:", back)
end
