extends Node

#region GameStateManager Signals
@warning_ignore("unused_signal")
signal switch_scene(old_scene : Node2D, new_scene : NodePath)

@warning_ignore("unused_signal")
signal reset

@warning_ignore("unused_signal")
signal reset_ink(image : Image)
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


@warning_ignore("unused_signal")
signal upgrade_taken(upgrade_name : String)

@warning_ignore("unused_signal")
signal remove_upgrades()
