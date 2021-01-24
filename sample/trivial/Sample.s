
if( typeof module !== 'undefined' )
require( 'wcloner' );
let _ = wTools;

var arr1 = [ 1, 2, 5, 9 ];
var arr2 = _.cloneJust( arr1 );

console.log( 'arr1', arr1 );
console.log( 'arr2', arr2 );
