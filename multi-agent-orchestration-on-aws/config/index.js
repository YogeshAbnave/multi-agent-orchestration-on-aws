"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.projectConfig = exports.projectConfigPath = exports.PresetStageType = void 0;
const chalk_1 = require("chalk");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const zod_1 = require("zod");
var PresetStageType;
(function (PresetStageType) {
    PresetStageType["Dev"] = "dev";
    PresetStageType["Prod"] = "prod";
})(PresetStageType || (exports.PresetStageType = PresetStageType = {}));
exports.projectConfigPath = path.join(__dirname, "project-config.json");
const baseSchema = {
    projectId: zod_1.z
        .string()
        .min(5)
        .max(15)
        .refine((value) => !/[ `!@#$%^&*()_+=\\[\]{};':"\\|,.<>\\/?~]/.test(value ?? ""), {
        message: "Name should contain only alphabets except '-' ",
    }),
    codeArtifact: zod_1.z.boolean(),
    midway: zod_1.z.boolean(),
    accounts: zod_1.z.record(zod_1.z.string(), zod_1.z.object({
        number: zod_1.z.string().length(12),
        region: zod_1.z.string(),
        midwaySecretId: zod_1.z.string().optional(),
    })),
};
const gitlabLength = zod_1.z.string().min(5).max(75);
const configSchema = zod_1.z.discriminatedUnion("codePipeline", [
    // Schema for projects with pipeline
    zod_1.z.object({
        ...baseSchema,
        codePipeline: zod_1.z.literal(true),
        gitlabGroup: gitlabLength,
        gitlabProject: gitlabLength,
    }),
    // Schema for projects without pipeline
    zod_1.z.object({
        ...baseSchema,
        codePipeline: zod_1.z.literal(false),
        gitlabGroup: gitlabLength.optional(),
        gitlabProject: gitlabLength.optional(),
    }),
]);
const loadProjectConfig = () => {
    let projectConfig;
    try {
        projectConfig = JSON.parse(fs.readFileSync(exports.projectConfigPath, "utf-8"));
    }
    catch {
        console.error((0, chalk_1.redBright)(`\n🛑 Missing project configuration file.\n`));
        process.exit(1);
    }
    const result = configSchema.safeParse(projectConfig);
    if (!result.success) {
        console.error((0, chalk_1.redBright)(`\n🛑 Malformed project configuration file.\n`));
        process.exit(1);
    }
    // if no stage is provided, the app defaults to prod so it must be present
    if (!projectConfig.accounts[PresetStageType.Prod]) {
        console.error((0, chalk_1.redBright)(`\n🛑 Missing prod account in configuration file.\n`));
        process.exit(1);
    }
    return projectConfig;
};
exports.projectConfig = loadProjectConfig();
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiaW5kZXguanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJpbmRleC50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUFBQSxpQ0FBa0M7QUFDbEMsdUNBQXlCO0FBQ3pCLDJDQUE2QjtBQUM3Qiw2QkFBd0I7QUFFeEIsSUFBWSxlQUdYO0FBSEQsV0FBWSxlQUFlO0lBQ3ZCLDhCQUFXLENBQUE7SUFDWCxnQ0FBYSxDQUFBO0FBQ2pCLENBQUMsRUFIVyxlQUFlLCtCQUFmLGVBQWUsUUFHMUI7QUE0QlksUUFBQSxpQkFBaUIsR0FBRyxJQUFJLENBQUMsSUFBSSxDQUFDLFNBQVMsRUFBRSxxQkFBcUIsQ0FBQyxDQUFDO0FBRTdFLE1BQU0sVUFBVSxHQUFHO0lBQ2YsU0FBUyxFQUFFLE9BQUM7U0FDUCxNQUFNLEVBQUU7U0FDUixHQUFHLENBQUMsQ0FBQyxDQUFDO1NBQ04sR0FBRyxDQUFDLEVBQUUsQ0FBQztTQUNQLE1BQU0sQ0FBQyxDQUFDLEtBQWEsRUFBRSxFQUFFLENBQUMsQ0FBQywwQ0FBMEMsQ0FBQyxJQUFJLENBQUMsS0FBSyxJQUFJLEVBQUUsQ0FBQyxFQUFFO1FBQ3RGLE9BQU8sRUFBRSxnREFBZ0Q7S0FDNUQsQ0FBQztJQUNOLFlBQVksRUFBRSxPQUFDLENBQUMsT0FBTyxFQUFFO0lBQ3pCLE1BQU0sRUFBRSxPQUFDLENBQUMsT0FBTyxFQUFFO0lBQ25CLFFBQVEsRUFBRSxPQUFDLENBQUMsTUFBTSxDQUNkLE9BQUMsQ0FBQyxNQUFNLEVBQUUsRUFDVixPQUFDLENBQUMsTUFBTSxDQUFDO1FBQ0wsTUFBTSxFQUFFLE9BQUMsQ0FBQyxNQUFNLEVBQUUsQ0FBQyxNQUFNLENBQUMsRUFBRSxDQUFDO1FBQzdCLE1BQU0sRUFBRSxPQUFDLENBQUMsTUFBTSxFQUFFO1FBQ2xCLGNBQWMsRUFBRSxPQUFDLENBQUMsTUFBTSxFQUFFLENBQUMsUUFBUSxFQUFFO0tBQ3hDLENBQUMsQ0FDTDtDQUNKLENBQUM7QUFDRixNQUFNLFlBQVksR0FBRyxPQUFDLENBQUMsTUFBTSxFQUFFLENBQUMsR0FBRyxDQUFDLENBQUMsQ0FBQyxDQUFDLEdBQUcsQ0FBQyxFQUFFLENBQUMsQ0FBQztBQUMvQyxNQUFNLFlBQVksR0FBRyxPQUFDLENBQUMsa0JBQWtCLENBQUMsY0FBYyxFQUFFO0lBQ3RELG9DQUFvQztJQUNwQyxPQUFDLENBQUMsTUFBTSxDQUFDO1FBQ0wsR0FBRyxVQUFVO1FBQ2IsWUFBWSxFQUFFLE9BQUMsQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDO1FBQzdCLFdBQVcsRUFBRSxZQUFZO1FBQ3pCLGFBQWEsRUFBRSxZQUFZO0tBQzlCLENBQUM7SUFDRix1Q0FBdUM7SUFDdkMsT0FBQyxDQUFDLE1BQU0sQ0FBQztRQUNMLEdBQUcsVUFBVTtRQUNiLFlBQVksRUFBRSxPQUFDLENBQUMsT0FBTyxDQUFDLEtBQUssQ0FBQztRQUM5QixXQUFXLEVBQUUsWUFBWSxDQUFDLFFBQVEsRUFBRTtRQUNwQyxhQUFhLEVBQUUsWUFBWSxDQUFDLFFBQVEsRUFBRTtLQUN6QyxDQUFDO0NBQ0wsQ0FBQyxDQUFDO0FBRUgsTUFBTSxpQkFBaUIsR0FBRyxHQUFrQixFQUFFO0lBQzFDLElBQUksYUFBNEIsQ0FBQztJQUNqQyxJQUFJLENBQUM7UUFDRCxhQUFhLEdBQUcsSUFBSSxDQUFDLEtBQUssQ0FBQyxFQUFFLENBQUMsWUFBWSxDQUFDLHlCQUFpQixFQUFFLE9BQU8sQ0FBQyxDQUFrQixDQUFDO0lBQzdGLENBQUM7SUFBQyxNQUFNLENBQUM7UUFDTCxPQUFPLENBQUMsS0FBSyxDQUFDLElBQUEsaUJBQVMsRUFBQyw0Q0FBNEMsQ0FBQyxDQUFDLENBQUM7UUFDdkUsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDLENBQUMsQ0FBQztJQUNwQixDQUFDO0lBRUQsTUFBTSxNQUFNLEdBQUcsWUFBWSxDQUFDLFNBQVMsQ0FBQyxhQUFhLENBQUMsQ0FBQztJQUNyRCxJQUFJLENBQUMsTUFBTSxDQUFDLE9BQU8sRUFBRSxDQUFDO1FBQ2xCLE9BQU8sQ0FBQyxLQUFLLENBQUMsSUFBQSxpQkFBUyxFQUFDLDhDQUE4QyxDQUFDLENBQUMsQ0FBQztRQUN6RSxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxDQUFDO0lBQ3BCLENBQUM7SUFFRCwwRUFBMEU7SUFDMUUsSUFBSSxDQUFDLGFBQWEsQ0FBQyxRQUFRLENBQUMsZUFBZSxDQUFDLElBQUksQ0FBQyxFQUFFLENBQUM7UUFDaEQsT0FBTyxDQUFDLEtBQUssQ0FBQyxJQUFBLGlCQUFTLEVBQUMsb0RBQW9ELENBQUMsQ0FBQyxDQUFDO1FBQy9FLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxDQUFDLENBQUM7SUFDcEIsQ0FBQztJQUVELE9BQU8sYUFBYSxDQUFDO0FBQ3pCLENBQUMsQ0FBQztBQUVXLFFBQUEsYUFBYSxHQUFrQixpQkFBaUIsRUFBRSxDQUFDIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgcmVkQnJpZ2h0IH0gZnJvbSBcImNoYWxrXCI7XG5pbXBvcnQgKiBhcyBmcyBmcm9tIFwiZnNcIjtcbmltcG9ydCAqIGFzIHBhdGggZnJvbSBcInBhdGhcIjtcbmltcG9ydCB7IHogfSBmcm9tIFwiem9kXCI7XG5cbmV4cG9ydCBlbnVtIFByZXNldFN0YWdlVHlwZSB7XG4gICAgRGV2ID0gXCJkZXZcIixcbiAgICBQcm9kID0gXCJwcm9kXCIsXG59XG5cbmV4cG9ydCBpbnRlcmZhY2UgQWNjb3VudENvbmZpZyB7XG4gICAgbnVtYmVyOiBzdHJpbmc7XG4gICAgcmVnaW9uOiBzdHJpbmc7XG4gICAgbWlkd2F5U2VjcmV0SWQ/OiBzdHJpbmc7XG59XG5cbmludGVyZmFjZSBCYXNlUHJvamVjdENvbmZpZyB7XG4gICAgcHJvamVjdElkOiBzdHJpbmc7XG4gICAgY29kZUFydGlmYWN0OiBib29sZWFuO1xuICAgIG1pZHdheTogYm9vbGVhbjtcbiAgICBhY2NvdW50czoge1xuICAgICAgICBba2V5OiBzdHJpbmddOiBBY2NvdW50Q29uZmlnO1xuICAgIH07XG59XG5pbnRlcmZhY2UgUHJvamVjdENvbmZpZ1dpdGhQaXBlbGluZSBleHRlbmRzIEJhc2VQcm9qZWN0Q29uZmlnIHtcbiAgICBjb2RlUGlwZWxpbmU6IHRydWU7XG4gICAgZ2l0bGFiR3JvdXA6IHN0cmluZztcbiAgICBnaXRsYWJQcm9qZWN0OiBzdHJpbmc7XG59XG5pbnRlcmZhY2UgUHJvamVjdENvbmZpZ1dpdGhvdXRQaXBlbGluZSBleHRlbmRzIEJhc2VQcm9qZWN0Q29uZmlnIHtcbiAgICBjb2RlUGlwZWxpbmU6IGZhbHNlO1xuICAgIGdpdGxhYkdyb3VwPzogc3RyaW5nO1xuICAgIGdpdGxhYlByb2plY3Q/OiBzdHJpbmc7XG59XG50eXBlIFByb2plY3RDb25maWcgPSBQcm9qZWN0Q29uZmlnV2l0aFBpcGVsaW5lIHwgUHJvamVjdENvbmZpZ1dpdGhvdXRQaXBlbGluZTtcblxuZXhwb3J0IGNvbnN0IHByb2plY3RDb25maWdQYXRoID0gcGF0aC5qb2luKF9fZGlybmFtZSwgXCJwcm9qZWN0LWNvbmZpZy5qc29uXCIpO1xuXG5jb25zdCBiYXNlU2NoZW1hID0ge1xuICAgIHByb2plY3RJZDogelxuICAgICAgICAuc3RyaW5nKClcbiAgICAgICAgLm1pbig1KVxuICAgICAgICAubWF4KDE1KVxuICAgICAgICAucmVmaW5lKCh2YWx1ZTogc3RyaW5nKSA9PiAhL1sgYCFAIyQlXiYqKClfKz1cXFxcW1xcXXt9Oyc6XCJcXFxcfCwuPD5cXFxcLz9+XS8udGVzdCh2YWx1ZSA/PyBcIlwiKSwge1xuICAgICAgICAgICAgbWVzc2FnZTogXCJOYW1lIHNob3VsZCBjb250YWluIG9ubHkgYWxwaGFiZXRzIGV4Y2VwdCAnLScgXCIsXG4gICAgICAgIH0pLFxuICAgIGNvZGVBcnRpZmFjdDogei5ib29sZWFuKCksXG4gICAgbWlkd2F5OiB6LmJvb2xlYW4oKSxcbiAgICBhY2NvdW50czogei5yZWNvcmQoXG4gICAgICAgIHouc3RyaW5nKCksXG4gICAgICAgIHoub2JqZWN0KHtcbiAgICAgICAgICAgIG51bWJlcjogei5zdHJpbmcoKS5sZW5ndGgoMTIpLFxuICAgICAgICAgICAgcmVnaW9uOiB6LnN0cmluZygpLFxuICAgICAgICAgICAgbWlkd2F5U2VjcmV0SWQ6IHouc3RyaW5nKCkub3B0aW9uYWwoKSxcbiAgICAgICAgfSlcbiAgICApLFxufTtcbmNvbnN0IGdpdGxhYkxlbmd0aCA9IHouc3RyaW5nKCkubWluKDUpLm1heCg3NSk7XG5jb25zdCBjb25maWdTY2hlbWEgPSB6LmRpc2NyaW1pbmF0ZWRVbmlvbihcImNvZGVQaXBlbGluZVwiLCBbXG4gICAgLy8gU2NoZW1hIGZvciBwcm9qZWN0cyB3aXRoIHBpcGVsaW5lXG4gICAgei5vYmplY3Qoe1xuICAgICAgICAuLi5iYXNlU2NoZW1hLFxuICAgICAgICBjb2RlUGlwZWxpbmU6IHoubGl0ZXJhbCh0cnVlKSxcbiAgICAgICAgZ2l0bGFiR3JvdXA6IGdpdGxhYkxlbmd0aCxcbiAgICAgICAgZ2l0bGFiUHJvamVjdDogZ2l0bGFiTGVuZ3RoLFxuICAgIH0pLFxuICAgIC8vIFNjaGVtYSBmb3IgcHJvamVjdHMgd2l0aG91dCBwaXBlbGluZVxuICAgIHoub2JqZWN0KHtcbiAgICAgICAgLi4uYmFzZVNjaGVtYSxcbiAgICAgICAgY29kZVBpcGVsaW5lOiB6LmxpdGVyYWwoZmFsc2UpLFxuICAgICAgICBnaXRsYWJHcm91cDogZ2l0bGFiTGVuZ3RoLm9wdGlvbmFsKCksXG4gICAgICAgIGdpdGxhYlByb2plY3Q6IGdpdGxhYkxlbmd0aC5vcHRpb25hbCgpLFxuICAgIH0pLFxuXSk7XG5cbmNvbnN0IGxvYWRQcm9qZWN0Q29uZmlnID0gKCk6IFByb2plY3RDb25maWcgPT4ge1xuICAgIGxldCBwcm9qZWN0Q29uZmlnOiBQcm9qZWN0Q29uZmlnO1xuICAgIHRyeSB7XG4gICAgICAgIHByb2plY3RDb25maWcgPSBKU09OLnBhcnNlKGZzLnJlYWRGaWxlU3luYyhwcm9qZWN0Q29uZmlnUGF0aCwgXCJ1dGYtOFwiKSkgYXMgUHJvamVjdENvbmZpZztcbiAgICB9IGNhdGNoIHtcbiAgICAgICAgY29uc29sZS5lcnJvcihyZWRCcmlnaHQoYFxcbvCfm5EgTWlzc2luZyBwcm9qZWN0IGNvbmZpZ3VyYXRpb24gZmlsZS5cXG5gKSk7XG4gICAgICAgIHByb2Nlc3MuZXhpdCgxKTtcbiAgICB9XG5cbiAgICBjb25zdCByZXN1bHQgPSBjb25maWdTY2hlbWEuc2FmZVBhcnNlKHByb2plY3RDb25maWcpO1xuICAgIGlmICghcmVzdWx0LnN1Y2Nlc3MpIHtcbiAgICAgICAgY29uc29sZS5lcnJvcihyZWRCcmlnaHQoYFxcbvCfm5EgTWFsZm9ybWVkIHByb2plY3QgY29uZmlndXJhdGlvbiBmaWxlLlxcbmApKTtcbiAgICAgICAgcHJvY2Vzcy5leGl0KDEpO1xuICAgIH1cblxuICAgIC8vIGlmIG5vIHN0YWdlIGlzIHByb3ZpZGVkLCB0aGUgYXBwIGRlZmF1bHRzIHRvIHByb2Qgc28gaXQgbXVzdCBiZSBwcmVzZW50XG4gICAgaWYgKCFwcm9qZWN0Q29uZmlnLmFjY291bnRzW1ByZXNldFN0YWdlVHlwZS5Qcm9kXSkge1xuICAgICAgICBjb25zb2xlLmVycm9yKHJlZEJyaWdodChgXFxu8J+bkSBNaXNzaW5nIHByb2QgYWNjb3VudCBpbiBjb25maWd1cmF0aW9uIGZpbGUuXFxuYCkpO1xuICAgICAgICBwcm9jZXNzLmV4aXQoMSk7XG4gICAgfVxuXG4gICAgcmV0dXJuIHByb2plY3RDb25maWc7XG59O1xuXG5leHBvcnQgY29uc3QgcHJvamVjdENvbmZpZzogUHJvamVjdENvbmZpZyA9IGxvYWRQcm9qZWN0Q29uZmlnKCk7XG4iXX0=