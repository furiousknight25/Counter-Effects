extends Node

#region GameStateManager Signals
@warning_ignore("unused_signal")
signal switch_scene(old_scene : Node2D, new_scene : NodePath)

@warning_ignore("unused_signal")
signal resetInking

#endregion


#region Upgrade Signals
@warning_ignore("unused_signal")
signal upgrade_player(upgrade : PlayerUpgrade)

@warning_ignore("unused_signal")
signal upgrade_ball(upgrade : BallUpgrade)

#endregion


@warning_ignore("unused_signal")
signal ball_hit


@warning_ignore("unused_signal")
signal enable_door
