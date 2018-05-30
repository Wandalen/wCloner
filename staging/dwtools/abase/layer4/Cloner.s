( function _Cloner_s_() {

'use strict'; /*aaa*/

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;
  _.include( 'wTraverser' );

}

var Self = _global_.wTools;
var _ = _global_.wTools;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

_.assert( _._traverser );

// --
// routines
// --

function _cloneMapUp( iteration )
{
  var iterator = iteration.iterator;

  _.assert( arguments.length === 1 );

  /* low copy degree */

  if( iteration.copyingDegree === 1 )
  {
    iteration.dst = iteration.src;
    return false;
  }

  /* map */

  var mapLike = _.mapLike( iteration.src ) || iteration.instanceAsMap;

  // if( _.construction.is( iteration.src ) )
  // debugger;

  if( !mapLike && !_.construction.is( iteration.src ) )
  {
    debugger;
    throw _.err
    (
      'Complex objets should have ' +
      ( iterator.technique === 'data' ? 'traverseData' : 'traverseObject' ) +
      ', but object ' + _.strTypeOf( iteration.src ) + ' at ' + ( iteration.path || '.' ), 'does not have such method','\n',
      iteration.src,'\n',
      'try to mixin wCopyable'
    );
  }

  /* */

  if( iteration.dst )
  {}
  else if( iteration.proto )
  {
    debugger;
    iteration.dst = new iteration.proto.constructor();
  }
  else
  {
    iteration.dst = _.entityMake( iteration.src );
  }

}

//

function _cloneMapEntryUp( iteration,newIteration )
{
  var iterator = iteration.iterator;
  var key = newIteration.key;

  _.assert( arguments.length === 2 );
  _.assert( iteration.iterator === newIteration.iterator );
  _.assert( iteration.copyingDegree > 1 );

  if( Config.debug )
  {
    var errd = 'Object does not have ' + key;
    _.assert( ( key in iteration.dst ) || Object.isExtensible( iteration.dst ),errd );
  }

  newIteration.cloningWithSetter = 0;
  if( !iterator.deserializing && newIteration.copyingDegree > 1 && iteration.dst._Accessors && iteration.dst._Accessors[ key ] )
  {
    _.assert( newIteration.copyingDegree > 0,'not expected' );
    newIteration.copyingDegree = 1;
    newIteration.cloningWithSetter = 1;
  }

}

//

function _cloneMapEntryDown( iteration,newIteration )
{
  var iterator = iteration.iterator;
  var key = newIteration.key;
  var val = newIteration.dst;

  _.assert( arguments.length === 2 );
  _.assert( iteration.iterator === newIteration.iterator );

  iteration.dst[ key ] = val;

  if( newIteration.cloningWithSetter )
  {
    var errd = 'Component setter "' + key + '" of object "' + iteration.dst.constructor.name + '" didn\'t copy data, but had to.';
    if( !( _.atomicIs( newIteration.src ) || iteration.dst[ key ] !== newIteration.src ) )
    {
      debugger;
      iteration.dst[ key ] = val;
    }
    _.assert( _.atomicIs( newIteration.src ) || iteration.dst[ key ] !== newIteration.src, errd );
  }

}

//

function _cloneArrayUp( iteration )
{
  var iterator = iteration.iterator;

  _.assert( arguments.length === 1 );
  _.assert( iteration.copyingDegree >= 1 );

  /* low copy degree */

  if( iteration.copyingDegree === 1 )
  {
    iteration.dst = iteration.src;
    return false;
  }

  if( iteration.dst )
  {}
  else if( iteration.proto )
  {
    debugger;
    iteration.dst = new iteration.proto( iteration.src.length );
  }
  else
  {
    iteration.dst = _.arrayMakeSimilar( iteration.src );
  }

}

//

function _cloneBufferUp( iteration )
{
  var iterator = iteration.iterator;

  _.assert( arguments.length === 1 );
  _.assert( iteration.copyingDegree >= 1 );

  if( iteration.copyingDegree >= 2 )
  {
    iteration.dst = _._arrayClone( iteration.src );
  }
  else
  {
    iteration.dst = iteration.src;
  }

}

//

function _cloner( routine,o )
{
  var routine = routine || _cloner;

  _.assert( arguments.length === 2 );
  _.routineOptions( routine,o );

  /* */

  o.onMapUp = _._cloneMapUp;
  o.onMapEntryUp = _._cloneMapEntryUp;
  o.onMapEntryDown = _._cloneMapEntryDown;
  o.onArrayUp = _._cloneArrayUp;
  o.onBufferUp = _._cloneBufferUp;

  var result = _._traverser( routine,o );

  return result;
}

_cloner.iterationDefaults = Object.create( _._traverser.iterationDefaults );
_cloner.defaults = Object.create( _._traverser.defaults2 );

//

function _cloneAct( iteration,iterator )
{
  return _._traverseAct( iteration,iterator );
}

//

function _clone( o )
{
  var r = _cloner( _clone,o );

  _.assert( !r.iterator.src || r.iterator.rootSrc );

  return _cloneAct( r,r.iterator );
}

_clone.defaults = _cloner.defaults;
_clone.iterationDefaults = _cloner.iterationDefaults;

// --
//
// --

function cloneJust( src )
{
  _.assert( arguments.length === 1 );

  var o = Object.create( null );
  o.src = src;

  _.routineOptions( cloneJust,o );

  return _._clone( o );
}

cloneJust.defaults =
{
  technique : 'object',
}

cloneJust.defaults.__proto__ = _clone.defaults;

//

function cloneObject( o )
{

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.routineOptions( cloneObject,o );

  var result = _clone( o );

  return result;
}

cloneObject.defaults =
{
  copyingAssociates : 1,
  technique : 'object',
}

cloneObject.defaults.__proto__ = _clone.defaults;

//

function cloneObjectMergingBuffers( o )
{
  var result = Object.create( null );
  var src = o.src;
  var descriptorsMap = o.src.descriptorsMap;
  var buffer = o.src.buffer;
  var data = o.src.data;

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.routineOptions( cloneObjectMergingBuffers,o );

  _.assert( _.objectIs( o.src.descriptorsMap ) );
  _.assert( _.bufferRawIs( o.src.buffer ) );
  _.assert( o.src.data !== undefined );
  _.assert( arguments.length === 1 )

  /* */

  var optionsForCloneObject = _.mapScreen( _.cloneObject.defaults,o );
  optionsForCloneObject.src = data;

  /* onString */

  optionsForCloneObject.onString = function onString( strString,iteration,iterator )
  {

    var id = _.strUnjoin( strString,[ '--buffer-->',_.strUnjoin.any,'<--buffer--' ] )

    if( id === undefined )
    return strString;

    var descriptor = descriptorsMap[ strString ];
    _.assert( descriptor !== undefined );

    var bufferConstructor = _global_[ descriptor[ 'bufferConstructorName' ] ];
    var offset = descriptor[ 'offset' ];
    var size = descriptor[ 'size' ];
    var sizeOfAtom = descriptor[ 'sizeOfAtom' ];
    var result = bufferConstructor ? new bufferConstructor( buffer,offset,size / sizeOfAtom ) : null;

    iteration.dst = result;

    return result;
  }

  optionsForCloneObject.onInstanceCopy = function onInstanceCopy( iteration,iterator )
  {

    var newIteration = iteration.iterationClone();
    newIteration.dst = null;
    newIteration.proto = null;

    var technique = newIteration.iterator.technique;
    newIteration.iterator.technique = 'data';
    newIteration.usingInstanceCopy = 0;
    _._cloneAct( newIteration,iterator );
    newIteration.iterator.technique = technique;

    iteration.src = newIteration.dst;

  }

  /* clone object */

  var result = _.cloneObject( optionsForCloneObject );

  return result;
}

cloneObjectMergingBuffers.defaults =
{
  copyingBuffers : 1,
}

cloneObjectMergingBuffers.defaults.__proto__ = cloneObject.defaults;

//

function cloneData( o )
{

  _.routineOptions( cloneData,o );

  var result = _clone( o );

  return result;
}

cloneData.defaults =
{
  technique : 'data',
  copyingAssociates : 0,
}

cloneData.defaults.__proto__ = _clone.defaults;

//

function cloneDataSeparatingBuffers( o )
{
  var result = Object.create( null );
  var buffers = [];
  var descriptorsArray = [];
  var descriptorsMap = Object.create( null );
  var size = 0;
  var offset = 0;

  _.routineOptions( cloneDataSeparatingBuffers,o );
  _.assert( arguments.length === 1 );

  /* onBuffer */

  o.onBuffer = function onBuffer( srcBuffer,iteration,iterator )
  {

    _.assert( _.bufferTypedIs( srcBuffer ),'not tested' );

    var index = buffers.length;
    var id = _.strJoin( '--buffer-->',index,'<--buffer--' );
    var bufferSize = srcBuffer ? srcBuffer.length*srcBuffer.BYTES_PER_ELEMENT : 0;
    size += bufferSize;

    var descriptor =
    {
      'bufferConstructorName' : srcBuffer ? srcBuffer.constructor.name : 'null',
      'sizeOfAtom' : srcBuffer ? srcBuffer.BYTES_PER_ELEMENT : 0,
      'offset' : -1,
      'size' : bufferSize,
      'index' : index,
    }

    buffers.push( srcBuffer );
    descriptorsArray.push( descriptor );
    descriptorsMap[ id ] = descriptor;

    iteration.dst = id;

  }

  /* clone data */

  result.data = _._clone( o );
  result.descriptorsMap = descriptorsMap;

  /* sort by atom size */

  descriptorsArray.sort( function( a,b )
  {
    return b[ 'sizeOfAtom' ] - a[ 'sizeOfAtom' ];
  });

  /* alloc */

  result.buffer = new ArrayBuffer( size );
  var dstBuffer = _.bufferBytesGet( result.buffer );

  /* copy buffers */

  for( var b = 0 ; b < descriptorsArray.length ; b++ )
  {

    var descriptor = descriptorsArray[ b ];
    var buffer = buffers[ descriptor.index ];
    var bytes = buffer ? _.bufferBytesGet( buffer ) : new Uint8Array();
    var bufferSize = descriptor[ 'size' ];

    descriptor[ 'offset' ] = offset;

    _.bufferMove( dstBuffer.subarray( offset,offset+bufferSize ),bytes );

    offset += bufferSize;

  }

  return result;
}

cloneDataSeparatingBuffers.defaults =
{
  copyingBuffers : 1,
}

cloneDataSeparatingBuffers.defaults.__proto__ = cloneData.defaults;

// --
// prototype
// --

var Proto =
{

  _cloneMapUp : _cloneMapUp,
  _cloneMapEntryUp : _cloneMapEntryUp,
  _cloneMapEntryDown : _cloneMapEntryDown,
  _cloneArrayUp : _cloneArrayUp,
  _cloneBufferUp : _cloneBufferUp,

  _cloner : _cloner,
  _cloneAct : _cloneAct,
  _clone : _clone,

  //

  cloneJust : cloneJust,
  cloneObject : cloneObject,
  cloneObjectMergingBuffers : cloneObjectMergingBuffers, /* experimental */
  cloneData : cloneData,
  cloneDataSeparatingBuffers : cloneDataSeparatingBuffers, /* experimental */

}

_.mapExtend( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
