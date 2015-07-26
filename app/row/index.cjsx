React = require 'react'
_ = require 'underscore'

Cell = require '../cell'
Mamba = require '../mamba' # can't require this :(
settings = require '../settings'
position = require '../util/position'
Immutable = require 'immutable'

Row = React.createClass

  propTypes:
    reset: React.PropTypes.bool.isRequired
    mamba: React.PropTypes.any.isRequired
    on_collision: React.PropTypes.func.isRequired

    row: React.PropTypes.number.isRequired

  componentWillMount: ->
    @setState cells: @reset @props, initial: true

  componentWillReceiveProps: (next_props) ->
    if next_props.reset
      @setState cells: @reset next_props
    else
      @setState cells: @update(next_props)

  shouldComponentUpdate: (next_props, next_state) ->
    next_props.reset or (next_state.cells isnt @state.cells)

  _update_cells: (callback) ->
    unless @state?.cells?
      throw new Error "state.cells doesn't exist"
    @state.cells.withMutations callback

  _create_cells: (props) ->
    if @state?.cells?
      throw new Error "state.cells already exists; use ._update_cells()"
    Immutable.List.of (for col in settings.GRID.range()
      if props.mamba.meets position.value_of(props.row, col)
        Cell.Snake
      else
        Cell.random())...

  reset: (props, options = {initial: false}) ->
    if options.initial
      @_create_cells(props)
    else
      @_update_cells (cells) =>
        cells.forEach (cell, col) =>
          if props.mamba.meets position.value_of(props.row, col)
            cells.set col, Cell.Snake
          else
            cells.set col, Cell.random()

  update: (props) ->
    @_update_cells (cells) =>
      cells.forEach (cell, col) =>
        if props.mamba.meets position.value_of(props.row, col)
          cells.set col, Cell.Snake
        else if cell is Cell.Snake
          cells.set col, Cell.Void

  render: ->
    {row, on_collision} = @props
    <div className="row">
      {@state.cells.map (cell, col) =>
        (<Cell on_collision={on_collision} key="cell-#{row}-#{col}"} content={cell}/>)}
    </div>


module.exports = Row;