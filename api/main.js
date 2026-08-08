"use strict";

import app from "./server.js";

const PORT = parseInt(process.env.PORT);
app.listen(PORT, () => {
    console.log(`Server running at port ${PORT}...`);
});
