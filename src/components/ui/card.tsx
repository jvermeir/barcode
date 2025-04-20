import React from "react";

export function Card({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
    return (
        <div className={`bg-white rounded-lg shadow-md ${className}`} {...props} />
    );
}

export function CardContent({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
    return (
        <div className={`p-4 ${className}`} {...props} />
    );
}
