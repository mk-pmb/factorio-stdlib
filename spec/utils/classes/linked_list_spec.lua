require('busted.runner')()

local LinkedList = require('stdlib/utils/classes/linked_list')
local World = require('spec/setup/world')

-- bootstrap world for _G.log
World.bootstrap()

local logspy = spy.on(_G, 'log')

describe('LinkedList', function()
    it('has a _class property pointing to the LinkedList class', function()
        local l = LinkedList:new()
        assert.are.equal(LinkedList, l._class)
    end)

    it('has a _class_name property indicating it is a LinkedList', function()
        local l = LinkedList:new()
        assert.are.equal('LinkedList', l._class_name)
    end)

    describe('.validate_integrity', function()
        it('should not validate the LinkedList class as a LinkedList',
        function()
            assert.has.errors(function()
                LinkedList:validate_integrity()
            end)
        end)

        it('should consider an empty list as valid.', function()
            assert.has_no.errors(function()
                local l = LinkedList:new()
                l:validate_integrity()
            end)
        end)

        it('should validate a sparse linked-list that includes itself as an \z
            item in multiple positions', function()
            local l = LinkedList:new()
            l:append(l)
            l:append(nil)
            l:append(l)
            l:append(nil)
            l:append(l)
            local n = l.next
            assert.are.equal(l, n.item)
            n = n.next
            assert.is.Nil(n.item)
            n = n.next
            assert.are.equal(l, n.item)
            n = n.next
            assert.is.Nil(n.item)
            n = n.next
            assert.are.equal(l, n.item)
            n = n.next
            assert.are.equal(l, n)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        context('should not validate a broken list', function()
            local l

            before_each(function()
                l = LinkedList:new()
                l:append('one')
                l:append('two')
                l:append('three')
            end)

            it('ie nil in .next', function()
                l.next.next.next = nil
                assert.has_errors(function()
                    l:validate_integrity()
                end)
            end)

            it('ie nil in .prev', function()
                l.next.next.prev = nil
                assert.has_errors(function()
                    l:validate_integrity()
                end)
            end)

            it('ie mismatched prev and next chains', function()
                local onenode = l.next
                local twonode = onenode.next
                local threenode = twonode.next
                onenode.next = threenode
                threenode.next = twonode
                twonode.next = l

                assert.has_errors(function()
                    l:validate_integrity()
                end)
            end)
        end)
    end)

    describe('.append', function()
        it('Adds to the end of the list', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.prev.prev.item)
            assert.are.equal('four',  l.prev.item)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        it('Returns the new node', function()
            local l = LinkedList:new()
            local node_1 = l:append('one')
            local node_2 = l:append('two')
            local node_3 = l:append('three')
            assert.are.equal(node_1, l.next)
            assert.are.equal(node_2, l.next.next)
            assert.are.equal(node_3, l.next.next.next)
            assert.are.equal(l,      l.next.next.next.next)
        end)
    end)

    describe('.prepend', function()
        it('Adds to the beginning of the list', function()
            local l = LinkedList:new()
            l:prepend('four')
            l:prepend('three')
            l:prepend('two')
            l:prepend('one')
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.prev.prev.item)
            assert.are.equal('four',  l.prev.item)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        it('Returns the new node', function()
            local l = LinkedList:new()
            local node_3 = l:prepend('three')
            local node_2 = l:prepend('two')
            local node_1 = l:prepend('one')
            assert.are.equal(node_1, l.next)
            assert.are.equal(node_2, l.next.next)
            assert.are.equal(node_3, l.next.next.next)
            assert.are.equal(l,      l.next.next.next.next)
        end)
    end)

    describe('.insert', function()
        it('Is equivalent to .append when invoked with one or zero arguments',
        function()
            local l = LinkedList:new()
            l:insert('one')
            l:insert('two')
            l:insert('three')
            l:insert('four')
            l:insert()
            l:insert('five')
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.next.next.next.item)
            assert.are.equal('four',  l.next.next.next.next.item)
            assert.is.Nil(            l.next.next.next.next.next.item)
            assert.are.equal('five',  l.next.next.next.next.next.next.item)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        it('Can insert items at arbitrary positions when invoked with a \z
            valid second argument', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:insert('two-and-a-half', 3)
            assert.are.equal('one',            l.next.item)
            assert.are.equal('two',            l.next.next.item)
            assert.are.equal('two-and-a-half', l.next.next.next.item)
            assert.are.equal('three',          l.next.next.next.next.item)
            assert.are.equal('four',           l.next.next.next.next.next.item)

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:insert('zero', 1)
            assert.are.equal('zero',  l.next.item)
            assert.are.equal('one',   l.next.next.item)
            assert.are.equal('two',   l.next.next.next.item)
            assert.are.equal('three', l.next.next.next.next.item)
            assert.are.equal('four',  l.next.next.next.next.next.item)

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:insert('five', 5)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.next.next.next.item)
            assert.are.equal('four',  l.next.next.next.next.item)
            assert.are.equal('five',  l.next.next.next.next.next.item)

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:insert('seven', 7)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.next.next.next.item)
            assert.are.equal('four',  l.next.next.next.next.item)
            assert.is.Nil(            l.next.next.next.next.next.item)
            assert.is.Nil(            l.next.next.next.next.next.next.item)
            assert.are.equal('seven', l.next.next.next.next.next.next.next.item)
        end)

        it('Will not insert insanely sparse items, defined as items whose \z
            indices would implicitly create more than 999 empty nodes in \z
            one operation, unless the LinkedList has the \z
            allow_insane_sparseness flag is set to true.', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            assert.has_no.errors(function()
                -- 1002 - 3 = 999 exactly
                l:insert('one-thousand-and-two', 1002)
            end)
            assert.are.equal(1002, l:length())
            assert.are.equal('one-thousand-and-two', l.prev.item)

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            assert.has_errors(function()
                -- 1003 - 3 = 1000, one too many
                l:insert('one-thousand-and-three', 1003)
            end)
            assert.are.equal(3, l:length(), 3)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('three', l.prev.item)

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l.allow_insane_sparseness = true
            assert.has_no.errors(function()
                l:insert('one-thousand-two-hundred-and-sixty-seven', 1267)
            end)
            assert.are.equal(1267, l:length())
            assert.are.equal('one', l.next.item)
            assert.are.equal('one-thousand-two-hundred-and-sixty-seven', l.prev.item)
        end)

        it('Will not accept non-index-y things as indexes.', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            assert.has_errors(function()
                l:insert('six-point-three', 6.3)
            end)
            assert.has_errors(function()
                l:insert('zero', 0)
            end)
            assert.has_errors(function()
                l:insert('zero-point-five', 0.5)
            end)
            assert.has_errors(function()
                l:insert('negative zero-point-five', -0.5)
            end)
            assert.has_errors(function()
                l:insert('negative ten', -10)
            end)
            assert.has_errors(function()
                l:insert('a function', function() end)
            end)
            assert.has_errors(function()
                l:insert('a table', {})
            end)
            assert.has_errors(function()
                l:insert('a chair', 'Eames')
            end)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('three', l.prev.item)
        end)

        it('Returns the new node', function()
            local l = LinkedList:new()
            local node_1 = l:insert('one')
            local node_2 = l:insert('two')
            local node_3 = l:insert('three')
            assert.are.equal(node_1, l.next)
            assert.are.equal(node_2, l.next.next)
            assert.are.equal(node_3, l.next.next.next)
            assert.are.equal(l,      l.next.next.next.next)
        end)
    end)

    describe('.remove', function()
        it('Will remove an item at a given position', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:append('five')
            l:remove(1)
            assert.are.equal('two',   l.next.item)
            assert.are.equal('three', l.next.next.item)
            assert.are.equal('four',  l.next.next.next.item)
            assert.are.equal('five',  l.next.next.next.next.item)
            assert.are.equal(4, l:length())

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:append('five')
            l:remove(3)
            assert.are.equal('one',  l.next.item)
            assert.are.equal('two',  l.next.next.item)
            assert.are.equal('four', l.next.next.next.item)
            assert.are.equal('five', l.next.next.next.next.item)
            assert.are.equal(4, l:length())

            l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            l:append('four')
            l:append('five')
            l:remove(5)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.next.next.next.item)
            assert.are.equal('four',  l.next.next.next.next.item)
            assert.are.equal(4, l:length())
        end)

        it('Will not accept non-index-y things as indexes.', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            assert.has_errors(function()
                l:remove(6.3)
            end)
            assert.has_errors(function()
                l:remove(0)
            end)
            assert.has_errors(function()
                l:remove(0.5)
            end)
            assert.has_errors(function()
                l:remove(-0.5)
            end)
            assert.has_errors(function()
                l:remove(-10)
            end)
            assert.has_errors(function()
                l:remove(function() end)
            end)
            assert.has_errors(function()
                l:remove({})
            end)
            assert.has_errors(function()
                l:remove('Eames')
            end)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('three', l.prev.item)
        end)
    end)

    describe('.copy', function()
        it('copies stuff', function()
            local l1 = LinkedList:new()
            l1:append('one')
            l1:append('two')
            l1:append('three')
            l1:append('four')
            local l2 = l1:copy()

            assert.is_not_equal(l1, l2)
            assert.are.equal(l2._class, l1._class)
            assert.has_no.errors(function()
                l1:validate_integrity()
            end)
            assert.has_no.errors(function()
                l2:validate_integrity()
            end)
            assert.are.equal('one',   l2.next.item)
            assert.are.equal('two',   l2.next.next.item)
            assert.are.equal('three', l2.next.next.next.item)
            assert.are.equal('four',  l2.next.next.next.next.item)
        end)

        it('does not create deep copies', function()
            local l1 = LinkedList:new()
            l1:append({'foo', 'bar'})
            local l2 = l1:copy()

            assert.is_not_equal(l1, l2)
            assert.are.equal(l1.next.item, l2.next.item)
        end)
    end)

    describe('.from_stack', function()
        it('creates an empty LinkedList from an empty table', function()
            local t = {}
            local l = LinkedList:from_stack(t)
            assert.is_not_equal(l, t)
            assert.are.equal(l, l.next)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        it('converts a simple stack table into an equivalent LinkedList',
        function()
            local t = { 'one', 'two', 'three' }
            local l = LinkedList:from_stack(t)
            assert.is_not_equal(l, t)
            assert.are.equal('one',   l.next.item)
            assert.are.equal('two',   l.next.next.item)
            assert.are.equal('three', l.next.next.next.item)
            assert.are.equal(l,       l.next.next.next.next)
            assert.is_true(l._is_LinkedList)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        it('converts a sparse pseudo-stack into a sparse LinkedList', function()
            local t = {'one', 'two', [4]='four'}
            local l = LinkedList:from_stack(t)
            assert.is_not_equal(l, t)
            assert.are.equal('one',  l.next.item)
            assert.are.equal('two',  l.next.next.item)
            assert.is.Nil(           l.next.next.next.item)
            assert.are.equal('four', l.next.next.next.next.item)
            assert.are.equal(l,      l.next.next.next.next.next)
            assert.has_no.errors(function()
                l:validate_integrity()
            end)
        end)

        it('refuses to create insanely sparse lists unless explicitly \z
            requested', function()
            -- 998 contiguous empty nodes
            local t = {'one', [999] = 'nine-hundred-ninety-nine'}
            assert.has_no.errors(function()
                local l = LinkedList:from_stack(t)
                assert.are.equal(999, l:length())
                assert.are.equal('one', l.next.item)
                assert.are.equal('nine-hundred-ninety-nine', l.prev.item)
                assert.has_no.errors(function()
                    l:validate_integrity()
                end)
            end)

            -- 999 contiguous empty nodes
            t = {'one', [1000] = 'one-thousand'}
            assert.has_no.errors(function()
                local l = LinkedList:from_stack(t)
                assert.are.equal(1000, l:length())
                assert.are.equal('one', l.next.item)
                assert.are.equal('one-thousand', l.prev.item)
                assert.has_no.errors(function()
                    l:validate_integrity()
                end)
            end)

            -- 1000 contiguous empty nodes
            t = {'one', [1001] = 'one-thousand-and-one'}
            assert.has.errors(function()
                LinkedList:from_stack(t)
            end)

            -- 1234 contiguous empty nodes (with insane sparseness override)
            t = {[1235] = '1235'}
            assert.has_no.errors(function()
                local l = LinkedList:from_stack(t, true)
                assert.are.equal(1235, l:length())
                assert.is.Nil(           l.next.item)
                assert.are.equal('1235', l.prev.item)
                assert.has_no.errors(function()
                    l:validate_integrity()
                end)
            end)
        end)

        it('ignores zero or non-natural nubmers, strings, and other things \z
            used as indices in the source stack, logging a warning', function()
            local function f() end
            local t = {
                [-4] = true,
                [0] = true,
                [1.5] = true,
                foo = true,
                [f] = true
            }
            logspy:clear()
            assert.has_no.errors(function()
                local l = LinkedList:from_stack(t)
                assert.has_no.errors(function()
                    l:validate_integrity()
                end)
                assert.is_true(l:is_empty())
                assert.spy(logspy).was.called(5)
            end)
        end)
    end)

    describe('.to_stack', function()
        it('converts an empty LinkedList into an empty table', function()
            local l = LinkedList:new()
            local t = l:to_stack()
            assert.are.same({}, t)
        end)

        it('converts a non-sparse LinkedList to an equivalent stack', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append('three')
            local t = l:to_stack()
            assert.are.same({'one', 'two', 'three'}, t)
        end)

        it('converts a sparse LinkedList to a sparse psuedo-stack', function()
            local l = LinkedList:new()
            l:append('one')
            l:append('two')
            l:append(nil)
            l:append('four')
            local t = l:to_stack()
            assert.are.same({'one', 'two', [4]='four'}, t)
        end)

        it('handles insanely sparse LinkedLists normally', function()
            local l = LinkedList:new()
            l:append('one')
            for i = 2, 1199 do
                l:append(nil)
            end
            l:append('twelve-hundred')
            assert.has_no.errors(function()
                local t = l:to_stack()
                assert.are.same({'one', [1200] = 'twelve-hundred'}, t)
            end)
        end)
    end)

    describe('.first_node', function()
        it('returns the first node in the list', function()
            local l = LinkedList:new()
            local firstnode = l:append('first')
            l:append('second')
            l:append('third')
            assert.are.equal(firstnode, l:first_node())
        end)

        it('returns nil for an empty list', function()
            local l = LinkedList:new()
            assert.is.Nil(l:first_node())
        end)
    end)

    describe('.last_node', function()
        it('returns the last node in the list', function()
            local l = LinkedList:new()
            l:append('first')
            l:append('second')
            local lastnode = l:append('third')
            assert.are.equal(lastnode, l:last_node())
        end)

        it('returns nil for an empty list', function()
            local l = LinkedList:new()
            assert.is.Nil(l:last_node())
        end)
    end)

    describe('.first_item', function()
        it('returns nil for an empty list', function()
            local l = LinkedList:new()
            assert.is.Nil(l:first_item())
        end)
    end)

    describe('.last_item', function()
        it('returns nil for an empty list', function()
            local l = LinkedList:new()
            assert.is.Nil(l:last_item())
        end)
    end)

    describe('.concatenate', function()
        it('returns a new list containing all the nodes from self \z
            followed by all the nodes from other', function()
            local la = LinkedList:from_stack({'one', 'two', 'three'})
            local lb = LinkedList:from_stack({'four', 'five', 'six'})
            local lab = la:concatenate(lb)
            assert.is_not_equal(la, lab)
            assert.is_not_equal(lb, lab)
            assert.are.same(
                {'one', 'two', 'three', 'four', 'five', 'six'},
                lab:to_stack()
            )
        end)
    end)

    describe('.nodes', function()
        it('returns an iterator which traverses the nodes in the list',
        function()
            local l = LinkedList:from_stack({1, 2, 3, 4, 5})
            local nodes = {}
            for node in l:nodes() do
                table.insert(nodes, node)
            end
            assert.are.same({
                l.next,
                l.next.next,
                l.next.next.next,
                l.next.next.next.next,
                l.next.next.next.next.next
            }, nodes)

            -- test empty list
            l = LinkedList:new()
            for node in l:nodes() do
                -- should never be reached
                assert.is_true(false)
            end
        end)
    end)

    describe('.items', function()
        it('returns an iterator which traverses the items in the list, \z
            skipping any nil items.', function()
            local l = LinkedList:from_stack({1, 2, 3, 4, 5})
            local thirdnode = l.next.next.next
            local items = {}
            for item in l:items() do
                table.insert(items, item)
            end
            assert.are.same({1, 2, 3, 4, 5}, items)

            -- test skipping nil items
            thirdnode.item = nil
            items = {}
            for item in l:items() do
                table.insert(items, item)
            end
            assert.are.same({1, 2, 4, 5}, items)

            -- test not skipping false items
            thirdnode.item = false
            items = {}
            for item in l:items() do
                table.insert(items, item)
            end
            assert.are.same({1, 2, false, 4, 5}, items)

            -- test empty list
            l = LinkedList:new()
            for item in l:items() do
                -- should never be reached
                assert.is_true(false)
            end
        end)
    end)
end)