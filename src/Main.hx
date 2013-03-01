import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		// HXP.world = new YourWorld();
	}

	public static function main() { new Main(); }

}