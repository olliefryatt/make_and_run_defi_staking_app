import { useEthers } from "@usedapp/core"
import { Button, makeStyles } from "@material-ui/core"

const useStyles = makeStyles((theme) => ({
    container: {
        padding: theme.spacing(4),
        display: "flex",
        justifyContent: "flex-end",
        gap: theme.spacing(1)
    },
}))



export const Header = () => {

    const classes = useStyles()

    const { account, activateBrowserWallet, deactivate } = useEthers()

    /** Check if there is a wallet connected */
    const isConnected = account !== undefined

    /** If connected show a button */
    return (
        <div className={classes.container}>
            <div>
                {isConnected ? ( /** Ternary operator, if connected do one thing, do other if not */
                    /** If connected */
                    <button 
                        color="primary"
                        onClick={deactivate}>
                        Disconnect
                    </button>
                ) : (
                    /** If not connected */
                    <button
                        color="primary"
                        onClick={() => activateBrowserWallet()}
                    >
                        Connect
                    </button>
                )}
            </div>
        </div>
    )
}