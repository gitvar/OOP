**grep\_v(pattern) → array **

**grep\_v(pattern) { \|obj\| block } → array**

Inverted version of
[\#grep](http://ruby-doc.org/core-2.3.0/Enumerable.html#method-i-grep). Returns
an array of every element in *enum* for which not `Pattern === element`.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(1..10).grep_v 2..5   #=> [1, 6, 7, 8, 9, 10]
res =(1..10).grep_v(2..5) { |v| v * 2 }
res                    #=> [2, 12, 14, 16, 18, 20]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

**group\_by { \|obj\| block } → a\_hash **

**group\_by → an\_enumerator**

Groups the collection by result of the block. Returns a hash where the keys are
the evaluated result from the block and the values are arrays of elements in the
collection that correspond to the key.

If no block is given an enumerator is returned.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(1..6).group_by { |i| i%3 }   #=> {0=>[3, 6], 1=>[1, 4], 2=>[2, 5]}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
